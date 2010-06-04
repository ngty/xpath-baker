$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'xpf/configuration'
require 'xpf/arguments_parsing'
require 'xpf/path_building'

module XPF

  class ModeAlreadyDeclaredError < Exception ; end

  class << self

    include PathBuilding
    include ArgumentsParsing

    ###
    # Applies global custom configuration.
    #
    #   XPF.configure do |config|
    #     # This will turn off case senstive matching, all xpath generated will
    #     # ignore chars casing
    #     config.case_sensitive = false
    #   end
    #
    # For a full list of configurable settings, see XPF::Configuration.
    #
    def configure(&blk)
      yield(Configuration)
    end

    ###
    # Befriending simply means adding the shortcut method xpf() to +someone+. If
    # +someone+ already has that method, a warning will be issued & no addition
    # is done. Currently, the only use case is to add xpf() to Object.
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
