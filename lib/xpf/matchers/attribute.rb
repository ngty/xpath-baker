module XPF
  module Matchers
    class Attribute < Matcher(:name, :value, :config)
      def condition
        value == nil_value ? n(a) : (
          !value.is_a?(Array) ? [ma, mv].join('=') : (
            ma.check_tokens(value.map{|val| q(d(val)) }, config.match_ordering?)
        ))
      end
    end
  end
end

