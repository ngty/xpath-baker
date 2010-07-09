module XPB

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

require 'xpb/matchers/values'
require 'xpb/matchers/matchable'
require 'xpb/matchers/group'
require 'xpb/matchers/text'
require 'xpb/matchers/any_text'
require 'xpb/matchers/literal'
require 'xpb/matchers/node'
require 'xpb/matchers/attribute'
require 'xpb/matchers/element'
