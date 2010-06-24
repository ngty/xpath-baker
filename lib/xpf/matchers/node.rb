module XPF
  module Matchers
    class Node < Matcher(:name, :value, :config)
      def condition
        value != nil_value ? me(mn, value) : (
          (config.comparison.negate? ? 'not(%s)' : '%s') % nn
        )
      end
    end
  end
end
