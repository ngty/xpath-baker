module XPF
  module Matchers
    class Text < Matcher(:value, :config)
      def condition
        expr = n(t)
        value == nil_value ? expr : [c(expr), c(q(value))].join('=')
      end
    end
  end
end
