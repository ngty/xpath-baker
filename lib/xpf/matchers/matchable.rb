module XPF

  class UnsupportedRegularExpression < Exception ; end

  module Matchers
    module Matchable

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
          String.translate_casing(str, config.case_sensitive?)
        end

        def q(str) #:nodoc:
          String.quote("#{str}")
        end

        def n(str) #:nodoc:
          config.normalize_space? ? %\normalize-space(#{str})\ : "#{str}"
        end

        def t(expr, tokens) #:nodoc:
          config.match_ordering? ? SortedArray.conditions_for(expr, tokens) :
            UnsortedArray.conditions_for(expr, tokens)
        end

        def r(expr, regexp) #:nodoc:
          Regexp.conditions_for(expr, regexp)
        end

        module String #:nodoc:

          LOWERCASE_CHARS = ('a'..'z').to_a * ''
          UPPERCASE_CHARS = ('A'..'Z').to_a * ''

          class << self

            def translate_casing(str, case_sensitive)
              case_sensitive ? str : %\translate(#{str},"#{UPPERCASE_CHARS}","#{LOWERCASE_CHARS}")\
            end

            def quote(str)
              !str.include?('"') ? %\"#{str}"\ : (
                'concat(%s)' % str.split('"',-1).map {|s| %\"#{s}"\ }.join(%\,'"',\)
              )
            end

          end
        end

        module SortedArray #:nodoc:
          class << self
            def conditions_for(expr, tokens)
              conditions = [UnsortedArray.conditions_for(expr, tokens)]
              tokens[1..-1].inject(tokens[0]) do |prev, curr|
                conditions << 'contains(substring-after(%s,%s),concat(" ",%s))' % [expr, prev, curr]
                curr
              end
              conditions.join(' and ')
            end
          end
        end

        module UnsortedArray #:nodoc:
          class << self
            def conditions_for(expr, tokens)
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

        module Regexp #:nodoc:
          class << self

            def conditions_for(expr, regexp)
              require 'pp'
              if (parsed = Reginald.parse(regexp)).literal?
                'contains(%s,%s)' % [expr, qt(parsed.to_s, true)]
              else
                condition = parsed.map do |unit|
                  send(:"r_#{unit.etype}", unit)# rescue raise UnsupportedRegularExpression
                end.join(' and ')
                count = (condition.size - condition.gsub('%s','').size) / 2
                condition % ([String.translate_casing(expr, !parsed.casefold?)]*count)
              end
            end

            def r_string(entry)
              val = qt(entry.value, !entry.casefold?)
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
              first = val[0..0]
              qt = lambda{|s| qt(s, !entry.casefold?) }
              'contains(translate(%s,%s,%s),%s)' % [
                '%s', qt[val], qt[first*(val.size)], qt[first]
              ]
            end

            def qt(str, case_sensitive)
              String.quote(case_sensitive ? str : str.downcase)
            end

          end
        end

    end

  end
end
