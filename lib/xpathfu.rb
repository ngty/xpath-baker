$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'xpathfu/version'
require 'xpathfu/configuration'
require 'xpathfu/arguments_parsing'
require 'xpathfu/path_building'

module XPathFu

  class ModeAlreadyDeclaredError < Exception ; end

  class << self

    include PathBuilding
    include ArgumentsParsing

    def configure(&blk)
      yield(Configuration)
    end

    protected

      def declare_mode_as(mode)
        if const_defined?(:MODE)
          raise ModeAlreadyDeclaredError.new("Mode has already been declared as :#{MODE} !!")
        else
          const_set(:MODE, mode)
        end
      end

  end
end
