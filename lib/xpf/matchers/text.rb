module XPF
  module Matchers
    class Text < Matcher(:value, :config)
      def condition
        value == nil_value ? n(t) : (
          !value.is_a?(Array) ? [mt, mv].join('=') : (
            mt.check_tokens(value.map{|val| q(d(val)) }, config.match_ordering?)
        ))
      end
    end
  end
end
