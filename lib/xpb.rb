$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'reginald'
require 'xpb/matchers'
require 'xpb/configuration'
require 'xpb/arguments'
require 'xpb/xpath'

module XPB

  class ModeAlreadyDeclaredError < Exception ; end
  class InvalidConfigModeError   < Exception ; end

  class << self

    ###
    # Do configuration, which can be:
    #
    # 1). Customize global configuration (see Configuration for all configurable settings):
    #
    #   XPB.configure do |config|
    #     # This will turn off case senstive matching, all xpath generated will
    #     # ignore chars casing
    #     config.case_sensitive = false
    #   end
    #
    # 2). Reset configuration to default:
    #
    #   XPB.configure(:reset)
    #
    def configure(mode = :update, &blk)
      case mode
      when :update then yield(Configuration)
      when :reset then Configuration.reset(&blk)
      else raise InvalidConfigModeError.new("Config mode :#{mode} is not supported !!")
      end
    end

    ###
    # Befriending simply means introducing the easier to type +someone.xpb+. If +someone+
    # already has that method, a warning will be issued & no addition is done.
    #
    # Currently, the only use case is to add xpb() to Object, thus usage becomes:
    #
    #   xpb.tr(...)
    #
    # Which has exactly the same effect as:
    #
    #   XPB.tr(...)
    #
    def befriends(someone)
      unless (@friends ||= []).include?(someone)
        if someone.method_defined?(:xpb)
          $stdout.puts %w{
            WARNING: XPB wants to befriend %s by giving it a shortcut method xpb(), but
            %s#xpb has already been defined. Neverthless, the rejected XPB stays friendly
            & XPB's goodies can still be accessed via the less easy to type XPB.*.
          }.join(' ') % ([someone]*2)
        else
          @friends << someone
          someone.send(:define_method, :xpb, lambda { XPB })
        end
      end
    end

    def is_config?(something)
      Configuration.describes_config?(something)
    end

    def normalize_config(config)
      Configuration.normalize(config)
    end

    def method_missing(element, *args)
      declare_support_for(element => {})
      send(element, *args)
    end

    protected

      attr_reader :supported_elements

      ###
      # This is to avoid XPB from running in multiple modes. Once mode has been declared
      # redeclaring will raise XPB::ModeAlreadyDeclaredError.
      #
      def declare_mode_as(mode) #:nodoc:
        if const_defined?(:MODE)
          raise ModeAlreadyDeclaredError.new("Mode has already been declared as :#{MODE} !!")
        else
          const_set(:MODE, mode)
        end
      end

      # TODO: Missing documentation !!
      def declare_support_for(elements_args)
        elements_args.each do |element, config|
          (@supported_elements ||= []) << element
          (class << self ; self ; end).send(:define_method, element) do |*args|
            XPath.new(element, config).build(*args)
          end
        end
      end

  end

  # NOTE: This is not tested !!
  XPB.befriends(Object)

end

