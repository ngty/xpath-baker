# Hacked version of the http://rubygems.org/gems/reginald

module Reginald

  class << self

    alias_method :orig_parse, :parse

    def parse(regexp)
      orig_parse(regexp).reconstruct
    end

  end

  class Expression

    def reconstruct
      anchors = []
      (
        @array = @array.inject([]) do |memo, unit|
          if unit.is_a?(Reginald::Anchor)
            anchors << unit.value
          elsif memo[-1].respond_to?(:<<)
            memo[-1] << unit
          elsif unit.is_a?(Character) && !unit.is_a?(CharacterClass)
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

  module SupportsFlagging

    def update_flags(flags)
      (@flags ||= {}).update(flags)
    end

    def start_of_line?
      !!(@flags ||= {})[:start_of_line]
    end

    def end_of_line?
      !!(@flags ||= {})[:end_of_line]
    end

  end

  class Characters < Collection

    include SupportsFlagging

    def initialize(entry)
      @array = [entry]
    end

    def <<(entry)
      @array << entry
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

    def value
      @array.map(&:value).join('')
    end

    def to_s(*args)
      @array.map(&:to_s).join('')
    end

  end

  class CharacterClass

    include SupportsFlagging

    def value(expanded=false)
      unexpanded_val = super()
      !expanded ? unexpanded_val : (
        pattern, tokens = /([a-z]\-[a-z]|[A-Z]\-[A-Z]|[0-9]\-[0-9])/, []
        while unexpanded_val =~ pattern && unexpanded_val.length >= 3
          tokens.concat(unexpanded_val.match(/(.*?)#{pattern}?/)[1..-1].reject{|t| t.empty? })
          unexpanded_val.sub!(tokens.join(''), '')
        end
        tokens << unexpanded_val unless unexpanded_val.empty?
        tokens.inject('') do |expanded_val, token|
          expanded_val + (
            token !~ pattern ? '' : (
              first, last = token.split('-')
              (first .. last).to_a.join('')
          ))
        end
      )
    end

    def etype
      :chars_set
    end

  end

end
