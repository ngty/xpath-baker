module XPF
  module Matchers
    module Values
      class UnsortedArray < Value(:expr, :tokens) #:nodoc:

        def to_condition
          tokens.map do |token|
            '(%s)' % [
              %|%s=#{token}|,
              %|contains(%s,concat(" ",#{token}," "))|,
              %|starts-with(%s,concat(#{token}," "))|,
              %|substring(%s,string-length(%s)+1-string-length(concat(" ",#{token})))=concat(" ",#{token})|,
            ].join(' or ') % ([expr]*5)
          end.join(' and ')
        end
      end

    end
  end
end
