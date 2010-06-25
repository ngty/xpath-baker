require 'rubygems'
require 'bacon'
require 'nokogiri'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'xpf'

module XPF
  module Spec
    module Matchers

      def self.new_klass(*attrs)
        (klass = Class.new(XPF::Matchers::Matcher(*attrs))).send(:define_method, :condition) do
          '((%s:%s:%s))' % [
            self.class.to_s.downcase.split('::')[-2..-1],
            attrs.map{|attr| diffentiable_val(self.send(attr)) }.join(',')
          ].flatten
        end
        klass
      end

      module X ; end
      module Y ; end

      { :Element => [:name, :value, :config],
        :Attribute => [:name, :value, :config],
        :Text => [:value, :config],
        :AnyText => [:value, :config],
        :Literal => [:value, :config]
      }.each do |name, attrs|
        [X,Y].each{|mod| mod.const_set(name, new_klass(*attrs)) }
      end
    end
  end
end

def merge_config(config1, config2)
  XPF::Configuration.new(
    XPF::Configuration.new(config1).to_hash.merge(config2)
  )
end

def diff_config(config1, config2=nil)
  config2 ||= XPF::Configuration.new({})
  (config1.to_hash.to_a - config2.to_hash.to_a).map(&:inspect) # .inject({}){|h,(k,v)| h.merge(k => v) }
end

def diffentiable_val(val)
  (val.respond_to?(:to_hash) ? diff_config(val) : val).to_s
end

def translate_casing(expr)
  uc, lc = [('A'..'Z'), ('a'..'z')].map {|r| r.to_a.join('') }
  %|translate(#{expr},"#{uc}","#{lc}")|
end

def each_xpf(&blk)
  [XPF, send(:xpf)].each {|r| yield(r) }
end

def check_tokens(expr, tokens, enforce_ordering=true)
  tokens.map do |token|
    '(%s)' % [
      %|%s=#{token}|,
      %|contains(%s,concat(" ",#{token}," "))|,
      %|starts-with(%s,concat(#{token}," "))|,
      %|substring(%s,string-length(%s)+1-string-length(concat(" ",#{token})))=concat(" ",#{token})|,
    ].join(' or ') % ([expr]*5)
  end.concat(
    !enforce_ordering ? [] : (
      prev = tokens[0]
      tokens[1..-1].map do |token|
        (prev, _ = token, 'contains(substring-after(%s,%s),concat(" ",%s))' % [expr, prev, token])[1]
      end
  )).join(' and ')
end

Bacon.summary_on_exit
