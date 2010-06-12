module XPF
  module Matchers
    class Attribute < Matcher(:name, :value, :config)
      def condition
        value == nil_value ? n(a) : [ma, mv].join('=')
      end
    end
  end
end

