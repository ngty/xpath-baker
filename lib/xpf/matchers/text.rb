module XPF
  module Matchers
    class Text < Matcher(:value, :config)
      def condition
        value == nil_value ? n(t) : [mt, mv].join('=')
      end
    end
  end
end
