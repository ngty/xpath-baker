module XPF
  module Matchers
    class Node < Matcher(:name, :value, :config)
      def condition
        value == nil_value ? nn : me(mn, value)
      end
    end
  end
end
