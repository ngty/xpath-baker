module XPathBaker
  module HTML
    module Matchers
      module TD

        module Matchable

          def condition
            value.empty? ? nil : valid_condition
          end

          def axial_cond(expr)
            (@axial_cond ||= ('self::*' == config.axial_node) ? '%s' : "#{config.axial_node}[%s]") % expr
          end

          def comparison(val)
            CM::AnyText.new(val, config).condition
          end

        end

        class Nil < CM::Matcher(:value, :config)

          include Matchable

          def condition
            './td[%s]' % axial_cond(comparison(nil_value))
          end

        end

        class Hash < CM::Matcher(:value, :config)

          include Matchable

          def valid_condition
            './td[%s]' %
              value.map do |field, val|
                # NOTE: Currently, content of <th/> cannot be axed. Even though it is very
                # easy to do so by just having axial_cond(me(mt,field)), we are not sure if
                # it is useful at all.
                th = %\ancestor::table[1]//th[%s][1]\ % axial_cond(comparison(field))
                td = axial_cond(comparison(val))
                'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, td]
              end.join(']/../td[')
          end

        end

        class Array < CM::Matcher(:value, :config)

          include Matchable

          def valid_condition
            glue = config.match_ordering? ? ']/following-sibling::td[' : ']/../td['
            './td[%s]' % [value.map{|val| axial_cond(comparison(val)) }.join(glue)]
          end

        end

      end
    end
  end
end
