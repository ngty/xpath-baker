module XPathFu
  module HTML
    module Tr

      def tr(*args)
        build(:tr, *args) do |match_attrs|
          [
            tr_cells_conditions(match_attrs.delete(:cells)),
            generic_attrs_conditions(match_attrs)
          ]
        end
      end

      private

        def tr_cells_conditions(cells)
          case cells
          when Hash then tr_cells_hash_conditions(cells)
          when Array then tr_cells_array_conditions(cells)
          when nil then nil
          else raise InvalidArgumentError.new('Match attribute :cells must be a Hash or Array.')
          end
        end

        def tr_cells_hash_conditions(cells)
          cells.empty? ? nil : cells.map do |field, val|
            th = %\./ancestor::table[1]//th[#{c(n(t))}=#{c(q(field))}][1]\
            %\./td[count(#{th}/preceding-sibling::th)+1][#{th}][#{c(n(t))}=#{c(q(val))}]\
          end.join('][')
        end

        def tr_cells_array_conditions(cells)
          cells.empty? ? nil : (
              if config.match_ordering
                './td' + cells.map {|val| %\[#{c(n(t))}=#{c(q(val))}]\ }.join('/following-sibling::td')
              else
                cells.map {|val| %\./td[#{c(n(t))}=#{c(q(val))}]\ }.join('][')
              end
          )
        end

    end
  end
end
