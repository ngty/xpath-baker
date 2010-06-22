module XPF
  module Matchers
    class AnyText < Matcher(:value, :config)
      def condition
        exprs = [n('text()'), n('.')]
        '(%s) or (%s)' % (value == nil_value ? exprs : exprs.map{|expr| me(mt(expr),value) })
      end
    end
  end
end
