module XPF
  module Matchers
    class Attribute < Matcher(:name, :value, :config)
      def condition
        expr = n("@#{name}")
        value == nil_value ? expr : [c(expr), c(q(value))].join('=')
      end
    end
  end
end

