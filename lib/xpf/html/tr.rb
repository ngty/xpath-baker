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
              './td[%s]' % mt
            end
          end

          class HashCells < XPF::Matchers::Matcher(:value, :config)
            def condition
              value.empty? ? nil : value.map do |field, val|
                th = %\./ancestor::table[1]//th[#{mt}=#{q(d(field))}][1]\
                %\./td[count(#{th}/preceding-sibling::th)+1][#{th}][#{mt}=#{q(d(val))}]\
              end.join('][')
            end
          end

          class ArrayCells < XPF::Matchers::Matcher(:value, :config)
            def condition
              value.empty? ? nil : (
                glue = config.match_ordering? ? ']/following-sibling::td[' : ']][./td['
                './td[%s]' % value.map{|val| %|#{mt}=#{q(d(val))}| }.join(glue)
              )
            end
          end
        end

    end
  end
end
