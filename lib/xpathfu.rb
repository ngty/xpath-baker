$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'xpathfu/version'
require 'xpathfu/errors'
require 'xpathfu/configuration'

module XPathFu
  class << self

    def declare_mode_as(mode)
      if const_defined?(:MODE)
        raise ModeAlreadyDeclaredError.new("Mode has already been declared as :#{MODE} !!")
      else
        const_set(:MODE, mode)
      end
    end

    def configure(&blk)
      yield(Configuration)
    end

  end
end
