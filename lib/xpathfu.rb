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

    def befriends(someone)
      unless (@friends ||= []).include?(someone)
        if someone.method_defined?(:xpf)
          $stdout.puts %w{
            WARNING: XPathFu wants to befriend %s by giving it a shortcut method xpf(),
            but %s#xpf has already been defined. Neverthless, the rejected XPathFu
            stays friendly & XPathFu's goodies can still be accessed via the more verbose
            XPathFu.* (eg. XPathfu.tr).
          }.join(' ') % ([someone]*2)
        else
          @friends << someone
          someone.send(:define_method, :xpf) do |element, *args|
            XPathFu.send(element, *args)
          end
        end
      end
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

# NOTE: This is not tested !!
XPathFu.befriends(Object)
