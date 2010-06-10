module XPF

  class InvalidAxisNodeError < Exception ; end

  module Matchers

    class Group < Matcher(:matchers, :config)

      def initialize(match_attrs, config)
        matchers = convert_to_matchers(match_attrs, config)
        super(matchers, config)
      end

      def condition
        (matchers.empty? ? './%s' : './%s[%s]') %
          [config.axis, matchers.map(&:condition).join('][')]
      end

      private

        def convert_to_matchers(match_attrs, config)
          match_attrs.map do |name, value|
            name == :text ?  Text.new(value, config) : Attribute.new(name, value, config)
          end
        end

    end

  end
end
