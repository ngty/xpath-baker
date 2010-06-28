require 'rubygems'
require 'bacon'
require 'nokogiri'

Bacon.summary_on_exit

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
            respond_to?(:matchers) && matchers.empty? ? nil :
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
        :Literal => [:value, :config],
        :Group => [:matchers, :config]
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
  if expr.is_a?(Array)
    expr.map{|e| translate_casing(e) }
  else
    %|translate(#{expr},"#{uc}","#{lc}")|
  end
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

def valid_config_settings_args(*args)
  mx = lambda{|name| XPF::Spec::Matchers::X.const_get(name) }
  my = lambda{|name| XPF::Spec::Matchers::Y.const_get(name) }
  {
    :greedy             => [{:greedy => true}, {:greedy => false}, %w{g}, %w{!g}],
    :match_ordering     => [{:match_ordering => true}, {:match_ordering => false}, %w{o}, %w{!o}],
    :case_sensitive     => [{:case_sensitive => true}, {:case_sensitive => false}, %w{c}, %w{!c}],
    :include_inner_text => [{:include_inner_text => true}, {:include_inner_text => false}, %w{i}, %w{!i}],
    :normalize_space    => [{:normalize_space => true}, {:normalize_space => false}, %w{n}, %w{!n}],
    :comparison         => [{:comparison => '!='}, {:comparison => '='}, %w{!=}, %w{!=}],
    :scope              => [{:scope => '//awe/some/'}, {:scope => '/wonderous/'}, %w{//awe/some/}, %w{/wonderous/}],
    :position           => [{:position => 0}, {:position => 10}, %w{0}, %w{10}],
    :axial_node         => [{:axial_node => :child}, {:axial_node => :parent}, %w{parent::*}, %w{child::*}],
    :element_matcher    => [{(k = :element_matcher) => mx[:Element]}, {k => my[:Element]}, [mx[:Element]], [mx[:Element]]],
    :attribute_matcher  => [{(k = :attribute_matcher) => mx[:Attribute]}, {k => my[:Attribute]}, [mx[:Attribute]], [my[:Attribute]]],
    :text_matcher       => [{(k = :text_matcher) => mx[:Text]}, {k => my[:Text]}, [mx[:Text]], [my[:Text]]],
    :any_text_matcher   => [{(k = :any_text_matcher) => mx[:AnyText]}, {k => my[:AnyText]}, [mx[:AnyText]], [my[:AnyText]]],
    :literal_matcher    => [{(k = :literal_matcher) => mx[:Literal]}, {k => my[:Literal]}, [mx[:Literal]], [my[:Literal]]],
    :group_matcher      => [{(k = :group_matcher) => mx[:Group]}, {k => my[:Group]}, [mx[:Group]], [my[:Group]]]
  }.select{|setting,_| args.include?(setting) }
end
