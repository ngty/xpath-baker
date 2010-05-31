module XPathFu
  module HTML
    module Tr

      def tr(*args)
        match_attrs = parse_args(*args)
        conditions = [
          tr_cells_conditions(match_attrs.delete(:cells)).join('][')
        ].compact
        %\#{scope}tr[#{conditions.join('][')}]\
      end

      def tr_cells_conditions(cells)
        case cells
        when Hash
          cells.map do |field, val|
            th = %\./ancestor::table[1]//th[#{c(n(t))}=#{c(q(field))}][1]\
            %\.//td[count(#{th}/preceding-sibling::th)+1][#{th}][#{c(n(t))}=#{c(q(val))}]\
          end
        else
          []
        end
      end

    end
  end
end
