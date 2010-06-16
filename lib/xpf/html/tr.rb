module XPF
  module HTML
    module TR

      def tr(*args)
        XPath.new(:tr, :group_matcher => TR::Matchers::Group).build(*args)
      end

      private

        module Matchers

          class Group < XPF::Matchers::Group
            def text_or_attr_matcher(name, val, config)
              name != :cells ? super : (
                klass = val == nil_value ? :'NilCells' : :"#{val.class.to_s}Cells"
                TR::Matchers.const_get(klass).new(val, config) rescue \
                  raise InvalidMatchAttrError.new('Match attribute :cells must be a Hash or Array !!')
              )
            end
          end

          class NilCells < XPF::Matchers::Matcher(:value, :config)
            def condition
              './td[%s]' % nt
            end
          end

          class HashCells < XPF::Matchers::Matcher(:value, :config)
            def condition
              value.empty? ? nil : value.map do |field, val|
                th = %\./ancestor::table[1]//th[%s][1]\ % me(mt, field)
                './td[count(%s/preceding-sibling::th)+1][%s][%s]' % [th, th, me(mt,val)]
              end.join('][')
            end
          end

          class ArrayCells < XPF::Matchers::Matcher(:value, :config)
            def condition
              value.empty? ? nil : (
                glue = config.match_ordering? ? ']/following-sibling::td[' : ']][./td['
                './td[%s]' % value.map{|val| me(mt,val) }.join(glue)
              )
            end
          end
        end

    end
  end
end
