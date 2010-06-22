module XPF

  class InvalidMatchAttrError < Exception ; end

  module Matchers
    class << self
      def Matcher(*attrs)
        klass, setters = Struct.new(*attrs), attrs.map {|attr| :"#{attr}=" }
        klass.send(:include, Matchable).send(:private, *setters)
      end
    end
  end

end

require 'xpf/matchers/matchable'
require 'xpf/matchers/group'
require 'xpf/matchers/text'
require 'xpf/matchers/any_text'
require 'xpf/matchers/literal'
require 'xpf/matchers/attribute'
