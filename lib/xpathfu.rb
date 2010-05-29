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

    def parse_args(*args)
      case args[0]
      when String
        new_config = lambda {|config| Configuration.merge(config) }
        case args.size
        when 2 then [args[0], new_config[{}], args[1]]
        when 3 then [args[0], new_config[args[2]], args[1]]
        else raise ArgumentError
        end
      when Hash then parse_args(*['//', *args])
      else raise ArgumentError
      end
    end

  end
end
