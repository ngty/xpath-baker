module XPF
  module Matchers
    class Text < Matcher(:value, :config)
      def condition
        value != nil_value ? me(mt, value) : (
          (config.comparison.negate? ? 'not(%s)' : '%s') % nt
        )
      end
    end
  end
end
