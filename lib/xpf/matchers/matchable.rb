module XPF

  class UnsupportedRegularExpression < Exception ; end

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

        def c(str, flag=(unassigned = true; false)) #:nodoc:
          translate = lambda{|s| %\translate(#{s},"#{UPPERCASE_CHARS}","#{LOWERCASE_CHARS}")\ }
          if unassigned
            config.case_sensitive? ? str : translate[str]
          else
            flag ? str : translate[str]
          end
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

        def r(expr, regexp)
          require 'pp'
          if (parsed = Reginald.parse(regexp)).literal?
            'contains(%s,%s)' % [expr, q(parsed.to_s)]
          else
            condition = parsed.map do |unit|
              send(:"r_#{unit.etype}", unit)# rescue raise UnsupportedRegularExpression
            end.join(' and ')
            count = (condition.size - condition.gsub('%s','').size) / 2
            condition % ([c(expr, !parsed.casefold?)]*count)
          end
        end

        def r_string(entry)
          val = q(entry.value)
          val = val.downcase if entry.casefold?
          if entry.start_of_line? && entry.end_of_line?
            '%s=%s' % ['%s', val]
          elsif entry.start_of_line?
            'starts-with(%s,%s)' % ['%s', val]
          elsif entry.end_of_line?
            'substring(%s,string-length(%s)+1-string-length(%s))=%s' % ['%s', '%s', val, val]
          else
            'contains(%s,%s)' % ['%s', val]
          end
        end

        def r_chars_set(entry)
          val = entry.value(true)
          qt = lambda{|s| q(entry.casefold? ? s.downcase : s) }
          'contains(translate(%s,%s,%s),%s)' % [
            '%s', qt[val], qt[val[0..0]*(val.size)], qt[val[0..0]]
          ]
        end

    end
  end
end
