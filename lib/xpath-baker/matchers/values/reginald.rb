# Hacked version of the http://rubygems.org/gems/reginald

class XPathBaker::InvalidRegexpQuantifier < Exception ; end

module Reginald

  class << self

    alias_method :orig_parse, :parse

    def parse(regexp)
      orig_parse(regexp).customize
    end

  end

  class Expression

    def customize
      anchors = []
      (
        @array = @array.inject([]) do |memo, unit|
          if unit.is_a?(Reginald::Anchor)
            anchors << unit.value
          elsif unit.is_a?(Character) && unit.quantifier.nil? && memo[-1].respond_to?(:<<)
            memo[-1] << unit
          elsif unit.is_a?(Character) && unit.quantifier.nil? && !unit.is_a?(CharacterClass)
            memo << Characters.new(unit)
          else
            memo << unit
          end
          memo
        end
      ).each_with_index do |unit, i|
        unit.update_flags(
          :start_of_line => i.zero? && anchors.include?('^'),
          :end_of_line => (i.succ - @array.size).zero? && anchors.include?('$')
        )
      end
      self
    end

  end

  module Extensions

    def update_flags(flags)
      (@flags ||= {}).update(flags)
    end

    def start_of_line?
      !!(@flags ||= {})[:start_of_line]
    end

    def end_of_line?
      !!(@flags ||= {})[:end_of_line]
    end

    def flags
      @flags ||= {}
    end

    def branchable?
      expanded_value.is_a?(Array)
    end

  end

  class Characters < Collection

    include Extensions

    def initialize(entry)
      @array = [entry]
    end

    def <<(entry)
      @array << entry
    end

    def to_a
      [TmpEntry.new(self, expanded_value, 1)]
    end

    def etype
      :string
    end

    def literal?
      @flags.empty? || [start_of_line?, end_of_line?].all?{|f| !f }
    end

    def casefold?
      @array[0].casefold?
    end

    def expanded_value
      @array.map(&:value).join('')
    end

    def to_s(*args)
      @array.map(&:to_s).join('')
    end

  end

  class CharacterClass

    include Extensions

    def expanded_value
      pattern, tokens = /([a-z]\-[a-z]|[A-Z]\-[A-Z]|[0-9]\-[0-9])/, []
      while value =~ pattern && value.length >= 3
        new_tokens = value.match(/(.*?)#{pattern}?/)[1..-1].reject{|t| t.empty? }
        tokens.concat(new_tokens)
        value.sub!(new_tokens.join(''), '')
      end
      tokens << value unless value.empty?
      tokens.inject('') do |expanded_val, token|
        expanded_val + (
          token !~ pattern ? stringify(token) : (
            first, last = token.split('-')
            tmp = (first .. last).to_a.join('')
            casefold? ? (tmp.downcase + tmp.upcase) : tmp
        ))
      end.split('').uniq.sort.join('')
    end

    def stringify(token)
      case token
      when '\d' then (0..9).to_a.join('')
      when '\w' then [0..9, 'a'..'z', 'A'..'Z'].map{|r| r.to_a }.flatten.join('') + '_'
      when '\s' then ' '
      else token.sub('\\','')
      end
    end

    def quantifier
      case (q = super || nil)
      when nil, '' then nil
      when Integer, Range then q
      when /\{(\d+)\}/ then $1.to_i
      when /\{(\d+)\,(\d+)\}/ then $1 == $2 ? $1.to_i : ($1.to_i .. $2.to_i)
      else raise XPathBaker::InvalidRegexpQuantifier
      end
    end

    def to_a
      val = expanded_value
      quantifier.to_a.map do |q|
        TmpEntry.new(self, val, q)
      end
    end

    def etype
      :chars_set
    end

    def branchable?
      quantifier.is_a?(Range)
    end

  end

  class Character

    include Extensions

    def expanded_value
      case quantifier
      when /\{(\d+)\}/
        value * $1.to_i
      when /\{(\d+),(\d+)\}/
        if $1 == $2
          value * $1.to_i
        else
          ($1.to_i .. $2.to_i).to_a.map{|i| value*i }
        end
      else raise XPathBaker::InvalidRegexpQuantifier
      end
    end

    def to_a
      expanded_value.map do |val|
        TmpEntry.new(self, val, 1)
      end
    end

    def etype
      :char
    end

  end

  class TmpEntry

    def initialize(entry, expanded_value, quantifier)
      @entry, @expanded_value, @quantifier = entry, expanded_value, quantifier
    end

    def expanded_value
      @expanded_value
    end

    def quantifier
      @quantifier
    end

    def method_missing(meth, *args)
      @entry.send(meth, *args)
    end

  end

end
