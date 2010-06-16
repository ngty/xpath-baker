module XPF
  module HTML
    module TR

      def tr(*args)
        XPath.new(:tr, :group_matcher => TR::Matchers::Group).build(*args)
      end

      private

        module Matchers

          class Group < XPF::Matchers::Group

            def condition
              cell_matchers, other_matchers = typed_matchers
              [
                cell_matchers && ('%s' % cell_matchers.map(&:condition).join('][')),
                other_matchers && mc(other_matchers.map(&:condition)),
              ].compact.join('')
            end

            protected

              def text_or_attr_matcher(name, val, config)
                name != :cells ? super : (
                  klass = val == nil_value ? :'NilCells' : :"#{val.class.to_s}Cells"
                  TR::Matchers.const_get(klass).new(val, config) rescue \
                    raise InvalidMatchAttrError.new('Match attribute :cells must be a Hash or Array !!')
                )
              end

              def typed_matchers
                _matchers = matchers.group_by{|m| [NilCells, HashCells, ArrayCells].any?{|klass| m.is_a?(klass) } }
                [true, false].map{|key| _matchers[key] ? _matchers[key] : nil }
              end

          end

          module Matchable

            def condition
              value.empty? ? nil : valid_condition
            end

            def axed_cond(expr)
              (@axed_cond ||= ('self::*' == config.axis) ? '%s' : "./#{config.axis}[%s]") % expr
            end

          end

          class NilCells < XPF::Matchers::Matcher(:value, :config)

            include Matchable

            def condition
              './td[%s]' % axed_cond(nt)
            end

          end

          class HashCells < XPF::Matchers::Matcher(:value, :config)

            include Matchable

            def valid_condition
              value.map do |field, val|
                # NOTE: Currently, content of <th/> cannot be axed. Even though it is very
                # easy to do so by just having axed_cond(me(mt,field)), we are not sure if
                # it is useful at all.
                th = %\./ancestor::table[1]//th[%s][1]\ % me(mt, field)
                './td[count(%s/preceding-sibling::th)+1][%s][%s]' % [th, th, axed_cond(me(mt,val))]
              end.join('][')
            end

          end

          class ArrayCells < XPF::Matchers::Matcher(:value, :config)

            include Matchable

            def valid_condition
              glue = config.match_ordering? ? ']/following-sibling::td[' : ']][./td['
              './td[%s]' % value.map{|val| axed_cond(me(mt,val)) }.join(glue)
            end

          end
        end

    end
  end
end
