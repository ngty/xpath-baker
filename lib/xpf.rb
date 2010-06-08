$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'xpf/configuration'
require 'xpf/arguments_parsing'
require 'xpf/path_building'

module XPF

  class ModeAlreadyDeclaredError < Exception ; end
  class InvalidConfigModeError   < Exception ; end

  class << self

    include PathBuilding
    include ArgumentsParsing

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
      when :reset then Configuration.reset
      else raise InvalidConfigModeError.new("Config mode :#{mode} is not supported !!")
      end
    end

    ###
    # Befriending simply means adding the shortcut method xpf() to +someone+. If
    # +someone+ already has that method, a warning will be issued & no addition
    # is done.
    #
    # When xpf() is available, using XPF can be shortened to:
    #
    #   xpf(:tr, ...)
    #
    # Which has exactly the same effect as:
    #
    #   XPF.tr(...)
    #
    # Currently, the only use case is to add xpf() to Object.
    #
    def befriends(someone)
      unless (@friends ||= []).include?(someone)
        if someone.method_defined?(:xpf)
          $stdout.puts %w{
            WARNING: XPF wants to befriend %s by giving it a shortcut method xpf(),
            but %s#xpf has already been defined. Neverthless, the rejected XPF
            stays friendly & XPF's goodies can still be accessed via the more verbose
            XPF.* (eg. XPathfu.tr).
          }.join(' ') % ([someone]*2)
        else
          @friends << someone
          someone.send(:define_method, :xpf) do |element, *args|
            XPF.send(element, *args)
          end
        end
      end
    end

    protected

      ###
      # This is to avoid XPF from running in multiple modes. Once mode has been declared
      # redeclaring will raise XPF::ModeAlreadyDeclaredError.
      #
      def declare_mode_as(mode)
        if const_defined?(:MODE)
          raise ModeAlreadyDeclaredError.new("Mode has already been declared as :#{MODE} !!")
        else
          const_set(:MODE, mode)
        end
      end

  end

end

# NOTE: This is not tested !!
XPF.befriends(Object)
