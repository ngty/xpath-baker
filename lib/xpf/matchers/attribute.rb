module XPF
  module Matchers

    class Attribute < Matcher(:name, :value, :config)
      def condition
        [c(n("@#{name}")), c(q(value))].join('=')
      end
    end

  end
end

