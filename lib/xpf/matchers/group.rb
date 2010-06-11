module XPF

  module Matchers

    class Group < Matcher(:matchers, :config)

      def initialize(match_attrs, config)
        matchers = convert_to_matchers(match_attrs, config)
        super(matchers, config)
      end

      def condition
        unless [matchers.empty?, config.axis.to_s =~ /^self/].all?
          (matchers.empty? ? './%s' : './%s[%s]') %
            [p(config.axis), matchers.map(&:condition).join('][')]
        end
      end

      private

        def convert_to_matchers(match_attrs, config)
          text_klass, attr_klass = [:text_matcher, :attr_matcher].map {|s| config.send(s) }
          match_attrs.to_a.map do |args|
            name, val = args.is_a?(Array) ? args : [args, nil_value]
            name == :text ? text_klass.new(val, config) : attr_klass.new(name, val, config)
          end
        end

    end

  end
end
