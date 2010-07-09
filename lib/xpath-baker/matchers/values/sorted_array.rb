module XPathBaker
  module Matchers
    module Values
      class SortedArray < UnsortedArray #:nodoc:

        def to_condition
          conditions = [super]
          tokens[1..-1].inject(tokens[0]) do |prev, curr|
            conditions << 'contains(substring-after(%s,%s),concat(" ",%s))' % [expr, prev, curr]
            curr
          end
          conditions.join(' and ')
        end

      end
    end
  end
end
