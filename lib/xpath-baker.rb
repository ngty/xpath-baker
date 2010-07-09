$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'reginald'
require 'xpath-baker/matchers'
require 'xpath-baker/configuration'
require 'xpath-baker/arguments'
require 'xpath-baker/xpath'

module XPathBaker

  class ModeAlreadyDeclaredError < Exception ; end
  class InvalidConfigModeError   < Exception ; end

  class << self

    ###
    # Do configuration, which can be:
    #
    # 1). Customize global configuration (see Configuration for all configurable settings):
    #
    #   XPathBaker.configure do |config|
    #     # This will turn off case senstive matching, all xpath generated will
    #     # ignore chars casing
    #     config.case_sensitive = false
    #   end
    #
    # 2). Reset configuration to default:
    #
    #   XPathBaker.configure(:reset)
    #
    def configure(mode = :update, &blk)
      case mode
      when :update then yield(Configuration)
      when :reset then Configuration.reset(&blk)
      else raise InvalidConfigModeError.new("Config mode :#{mode} is not supported !!")
      end
    end

    # ###
    # # Befriending simply means introducing the easier to type +someone.xpath-baker+. If +someone+
    # # already has that method, a warning will be issued & no addition is done.
    # #
    # # Currently, the only use case is to add xpath-baker() to Object, thus usage becomes:
    # #
    # #   xpath-baker.tr(...)
    # #
    # # Which has exactly the same effect as:
    # #
    # #   XPathBaker.tr(...)
    # #
    # def befriends(someone)
    #   unless (@friends ||= []).include?(someone)
    #     if someone.method_defined?(:xpath-baker)
    #       $stdout.puts %w{
    #         WARNING: XPathBaker wants to befriend %s by giving it a shortcut method xpath-baker(), but
    #         %s#xpath-baker has already been defined. Neverthless, the rejected XPathBaker stays friendly
    #         & XPathBaker's goodies can still be accessed via the less easy to type XPathBaker.*.
    #       }.join(' ') % ([someone]*2)
    #     else
    #       @friends << someone
    #       someone.send(:define_method, :xpath-baker, lambda { XPathBaker })
    #     end
    #   end
    # end

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
      # This is to avoid XPathBaker from running in multiple modes. Once mode has been declared
      # redeclaring will raise XPathBaker::ModeAlreadyDeclaredError.
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

  # # NOTE: This is not tested !!
  # XPathBaker.befriends(Object)

end

