module XPF
  module Matchers
    module Matchable

      LOWERCASE_CHARS = ('a'..'z').to_a * ''
      UPPERCASE_CHARS = ('A'..'Z').to_a * ''
      NIL_VALUE = Struct.new('NIL_VALUE')

      protected

        def me(expr, val)
          !val.is_a?(Array) ? %|#{expr}=#{mv(val)}| : t(expr, val.map{|_val| mv(_val) })
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
          ('self::*' == config.axial_node && conditions.empty?) ? nil :
            f('./%s' % config.axial_node, conditions.empty? ? nil : ('[%s]' % conditions.join('][')))
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
          !str.include?('"') ? %\"#{str}"\ : (
            'concat(%s)' % str.split('"',-1).map {|s| %\"#{s}"\ }.join(%\,'"',\)
          )
        end

        def n(str) #:nodoc:
          config.normalize_space? ? %\normalize-space(#{str})\ : "#{str}"
        end

        def f(axial_node, conditions) #:nodoc:
          '%s%s%s' % (
            if (pos = config.position).nil?
              [axial_node, conditions, nil]
            else
              pos.start? ? [axial_node, pos, conditions] : [axial_node, conditions, pos]
            end
          )
        end

        # def v(expr, default_val) #:nodoc:
        #   expr = (send(expr) rescue expr) if expr.is_a?(Symbol)
        #   expr || default_val
        # end

        def t(expr, tokens) #:nodoc:
          tokens.map{|tk| t1(expr,tk) }.concat(
            !config.match_ordering? ? [] : (
              prev = tokens[0]
              tokens[1..-1].map{|curr| (prev, condition = t2(expr, prev, curr))[1] }
          )).join(' and ')
        end

        def t1(expr, token) #:nodoc:
          '(%s)' % [
            %|%s=#{token}|,
            %|contains(%s,concat(" ",#{token}," "))|,
            %|starts-with(%s,concat(#{token}," "))|,
            %|substring(%s,string-length(%s)+1-string-length(concat(" ",#{token})))=concat(" ",#{token})|,
          ].join(' or ') % ([expr]*5)
        end

        def t2(expr, prev_token, curr_token) #:nodoc:
          [
            curr_token,
            'contains(substring-after(%s,%s),concat(" ",%s))' % [expr, prev_token, curr_token]
          ]
        end

    end
  end
end
