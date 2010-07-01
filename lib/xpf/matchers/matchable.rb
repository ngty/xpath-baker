module XPF
  module Matchers
    module Matchable

      LOWERCASE_CHARS = ('a'..'z').to_a * ''
      UPPERCASE_CHARS = ('A'..'Z').to_a * ''

      class << (NIL_VALUE = Struct.new('NIL_VALUE'))
        def to_s ; 'XPF_NIL_VALUE' ; end
      end

      protected

        def me(expr, val, skip_negate=false)
          (!skip_negate && config.comparison.negate? ? 'not(%s)' : '%s') % (
            if val.is_a?(Array)
              t(expr, val.map{|_val| mv(_val) })
            else
              [expr, config.comparison, mv(val)].join('')
            end
          )
        end

        def mv(val)
          q(config.case_sensitive? ? val : val.to_s.downcase)
        end

        def mt(val = nil)
          c(val || nt)
        end

        def mn(val = nil)
          c(val || nn)
        end

        def mc(conditions)
          if conditions.empty?
            config.axial_node == 'self::*' ? nil : config.axial_node
          else
            '%s[%s]' % [config.axial_node, conditions.sort.join('][')]
          end
        end

        def nn
          n(name)
        end

        def nt
          n(config.include_inner_text? ? '.' : 'text()')
        end

        def nil_value
          NIL_VALUE
        end

      private

        def c(str) #:nodoc:
          config.case_sensitive? ? str :
            %\translate(#{str},"#{UPPERCASE_CHARS}","#{LOWERCASE_CHARS}")\
        end

        def q(str) #:nodoc:
          !(str = "#{str}").include?('"') ? %\"#{str}"\ : (
            'concat(%s)' % str.split('"',-1).map {|s| %\"#{s}"\ }.join(%\,'"',\)
          )
        end

        def n(str) #:nodoc:
          config.normalize_space? ? %\normalize-space(#{str})\ : "#{str}"
        end

        def t(expr, tokens) #:nodoc:
          tokens.map{|tk| t_condition(expr,tk) }.concat(
            !config.match_ordering? ? [] : (
              prev = tokens[0]
              tokens[1..-1].map{|curr| (prev, condition = t_order(expr, prev, curr))[1] }
          )).join(' and ')
        end

        def t_condition(expr, token) #:nodoc:
          '(%s)' % [
            %|%s=#{token}|,
            %|contains(%s,concat(" ",#{token}," "))|,
            %|starts-with(%s,concat(#{token}," "))|,
            %|substring(%s,string-length(%s)+1-string-length(concat(" ",#{token})))=concat(" ",#{token})|,
          ].join(' or ') % ([expr]*5)
        end

        def t_order(expr, prev_token, curr_token) #:nodoc:
          [
            curr_token,
            'contains(substring-after(%s,%s),concat(" ",%s))' % [expr, prev_token, curr_token]
          ]
        end

        # def f(axial_node, conditions) #:nodoc:
        #   '%s%s%s' % (
        #     if (pos = config.position).nil?
        #       [axial_node, conditions, nil]
        #     else
        #       pos.start? ? [axial_node, pos, conditions] : [axial_node, conditions, pos]
        #     end
        #   )
        # end

        # def v(expr, default_val) #:nodoc:
        #   expr = (send(expr) rescue expr) if expr.is_a?(Symbol)
        #   expr || default_val
        # end

    end
  end
end
