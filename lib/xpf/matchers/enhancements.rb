module XPF
  module Matchers
    module Enhancements

      module String

        def check_tokens(tokens, enforce_ordering)
          tokens.map{|token| check_token(token) }.concat(
            !enforce_ordering ? [] : (
              prev = tokens[0]
              tokens[1..-1].map do |token|
                (prev, _ = token, 'contains(substring-after(%s,%s),concat(" ",%s))' % [self, prev, token])[1]
              end
          )).join(' and ')
        end

        def check_token(token)
          '(%s)' % [
            %|%s=#{token}|,
            %|contains(%s,concat(" ",#{token}," "))|,
            %|starts-with(%s,concat(#{token}," "))|,
            %|substring(%s,string-length(%s)+1-string-length(concat(" ",#{token})))=concat(" ",#{token})|,
          ].join(' or ') % ([self]*5)
        end

        alias_method :apply_check_for_token, :check_token

      end

    end
  end
end
