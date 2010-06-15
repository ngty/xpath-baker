module XPF
  module Matchers
    class Text < Matcher(:value, :config)
      def condition
        value == nil_value ? n(t) : (
          !value.is_a?(Array) ? [mt, mv].join('=') : (
            value.map(&:to_s).map do |val|
              mt.apply_check_for_token(q(d(val)))
            end.join(' and ')
        ))
      end
    end
  end
end
