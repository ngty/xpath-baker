$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'xpf/matchers'
require 'xpf/configuration'
require 'xpf/arguments'
require 'xpf/xpath'

module XPF

  class ModeAlreadyDeclaredError < Exception ; end
  class InvalidConfigModeError   < Exception ; end

  class << self

    ###
    # Do configuration, which can be:
    #
    # 1). Customize global configuration (see Configuration for all configurable settings):
    #
    #   XPF.configure do |config|
    #     # This will turn off case senstive matching, all xpath generated will
    #     # ignore chars casing
    #     config.case_sensitive = false
    #   end
    #
    # 2). Reset configuration to default:
    #
    #   XPF.configure(:reset)
    #
    def configure(mode = :update, &blk)
      case mode
      when :update then yield(Configuration)
      when :reset then Configuration.reset(&blk)
      else raise InvalidConfigModeError.new("Config mode :#{mode} is not supported !!")
      end
    end

    ###
    # Befriending simply means introducing the easier to type +someone.xpf+. If +someone+
    # already has that method, a warning will be issued & no addition is done.
    #
    # Currently, the only use case is to add xpf() to Object, thus usage becomes:
    #
    #   xpf.tr(...)
    #
    # Which has exactly the same effect as:
    #
    #   XPF.tr(...)
    #
    def befriends(someone)
      unless (@friends ||= []).include?(someone)
        if someone.method_defined?(:xpf)
          $stdout.puts %w{
            WARNING: XPF wants to befriend %s by giving it a shortcut method xpf(), but
            %s#xpf has already been defined. Neverthless, the rejected XPF stays friendly
            & XPF's goodies can still be accessed via the less easy to type XPF.*.
          }.join(' ') % ([someone]*2)
        else
          @friends << someone
          someone.send(:define_method, :xpf, lambda { XPF })
        end
      end
    end

    def is_config?(something)
      Configuration.is_config?(something)
    end

    protected

      ###
      # This is to avoid XPF from running in multiple modes. Once mode has been declared
      # redeclaring will raise XPF::ModeAlreadyDeclaredError.
      #
      def declare_mode_as(mode) #:nodoc:
        if const_defined?(:MODE)
          raise ModeAlreadyDeclaredError.new("Mode has already been declared as :#{MODE} !!")
        else
          const_set(:MODE, mode)
        end
      end

  end

  # NOTE: This is not tested !!
  XPF.befriends(Object)

end

