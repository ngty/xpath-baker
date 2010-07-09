module XPathBaker

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

require 'xpath-baker/matchers/values'
require 'xpath-baker/matchers/matchable'
require 'xpath-baker/matchers/group'
require 'xpath-baker/matchers/text'
require 'xpath-baker/matchers/any_text'
require 'xpath-baker/matchers/literal'
require 'xpath-baker/matchers/node'
require 'xpath-baker/matchers/attribute'
require 'xpath-baker/matchers/element'
