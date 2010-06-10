module XPF
  module Matchers

    class Text < Matcher(:value, :config)
      def condition
        [c(n(t)), c(q(value))].join('=')
      end
    end

  end
end
