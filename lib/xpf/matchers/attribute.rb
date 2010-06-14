module XPF
  module Matchers
    class Attribute < Matcher(:name, :value, :config)
      def condition
        value == nil_value ? n(a) : (
          !value.is_a?(Array) ? [ma, mv].join('=') : (
            value.map(&:to_s).map do |val|
              ma.apply_check_for_token(q(config.case_sensitive? ? val : val.downcase))
            end.join(' and ')
        ))
      end
    end
  end
end

