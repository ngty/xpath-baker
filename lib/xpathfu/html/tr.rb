module XPathFu
  module HTML
    module Tr

      def tr(*args)
        match_attrs = parse_args(*args)
        conditions = [
          tr_cells_conditions(match_attrs.delete(:cells))
        ].compact
        "#{scope}tr%s" % (conditions.empty? ? '' : "[#{conditions.join('][')}]")
      end

      def tr_cells_conditions(cells)
        conditions =
          case cells
          when Hash
            cells.map do |field, val|
              th = %\./ancestor::table[1]//th[#{c(n(t))}=#{c(q(field))}][1]\
              %\.//td[count(#{th}/preceding-sibling::th)+1][#{th}][#{c(n(t))}=#{c(q(val))}]\
            end.join('][')
          when Array
            cells.empty? ? '' :
              './/td' + cells.map {|val| %\[#{c(n(t))}=#{c(q(val))}]\ }.join('/following-sibling::td')
          else
            raise InvalidArgumentError.new('Match attribute :cells must be a Hash or Array.')
          end
        conditions.empty? ? nil : conditions
      end

    end
  end
end
