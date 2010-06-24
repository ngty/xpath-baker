module XPF
  module Matchers
    class AnyText < Matcher(:value, :config)
      def condition
        (config.comparison.negate? ? 'not(%s)' : '%s') % (
          exprs = [n('text()'), n('.')]
          '(%s) or (%s)' % (value == nil_value ? exprs : exprs.map{|expr| me(mt(expr),value,true) })
        )
      end
    end
  end
end
