module XPF
  module HTML
    module Matchers
      module Cells

        module Matchable

          def condition
            value.empty? ? nil : valid_condition
          end

          def axed_cond(expr)
            (@axed_cond ||= ('self::*' == config.axis) ? '%s' : "#{scope}#{config.axis}[%s]") % expr
          end

        end

        class Nil < XPF::Matchers::Matcher(:scope, :value, :config)

          include Matchable

          def condition
            '%std[%s]' % [scope, axed_cond(nt)]
          end

        end

        class Hash < XPF::Matchers::Matcher(:scope, :value, :config)

          include Matchable

          def valid_condition
            value.map do |field, val|
              # NOTE: Currently, content of <th/> cannot be axed. Even though it is very
              # easy to do so by just having axed_cond(me(mt,field)), we are not sure if
              # it is useful at all.
              th = %\./ancestor::table[1]//th[%s][1]\ % me(mt, field)
              '%std[count(%s/preceding-sibling::th)+1][%s][%s]' % [scope, th, th, axed_cond(me(mt,val))]
            end.join('][')
          end

        end

        class Array < XPF::Matchers::Matcher(:scope, :value, :config)

          include Matchable

          def valid_condition
            glue = config.match_ordering? ? ']/following-sibling::td[' : (']][%std['%scope)
            '%std[%s]' % [scope, value.map{|val| axed_cond(me(mt,val)) }.join(glue)]
          end

        end

      end
    end
  end
end
