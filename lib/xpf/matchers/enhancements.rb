module XPF
  module Matchers
    module Enhancements

      module String

        def apply_check_for_token(token)
          '(%s)' % [
            %|%s=#{token}|,
            %|contains(%s,concat(" ",#{token}," "))|,
            %|starts-with(%s,concat(#{token}," "))|,
            %|substring(%s,string-length(%s)+1-string-length(concat(" ",#{token})))=concat(" ",#{token})|,
          ].join(' or ') % ([self]*5)
        end

      end

    end
  end
end
