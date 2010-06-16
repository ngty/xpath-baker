module XPF
  module Matchers
    class Attribute < Matcher(:name, :value, :config)
      def condition
        value == nil_value ? na : me(ma, value)
      end
    end
  end
end

