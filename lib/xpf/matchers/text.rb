module XPF
  module Matchers
    class Text < Matcher(:value, :config)
      def condition
        value == nil_value ? nt : me(mt, value)
      end
    end
  end
end
