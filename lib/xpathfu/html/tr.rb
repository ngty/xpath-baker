module XPathFu
  module HTML
    module Tr

      def tr(*args)
        @scope, @config, @match_attrs = parse_args(*args)
        %\#{@scope}tr[#{tr_cells_conditions(@match_attrs.delete(:cells)).join('][')}]\
      end

      def tr_cells_conditions(cells)
        case cells
        when Hash
          cells.map do |field, val|
            header = %\./ancestor::table[1]//th[normalize-space(.)="#{field}"][1]\
            %\.//td[count(#{header}/preceding-sibling::th)+1][#{header}][normalize-space(.)="#{val}"]\
          end
        else
          []
        end
      end

    end
  end
end
