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
          (config.match_ordering? ? SortedArray : UnsortedArray).
            new(expr, tokens).to_condition
        end

        def r(expr, regexp) #:nodoc:
          Regexp.new(expr, regexp).to_condition
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

        def self.Value(*attrs) #:nodoc:
          Struct.new(*attrs)
        end

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

        class Regexp < Value(:expr, :regexp) #:nodoc:

          def to_condition
            insert_expr(
              if (parsed = Reginald.parse(regexp)).literal?
                'contains(%s,%s)' % [t('%s', !parsed.casefold?), qc(parsed.to_s)]
              else
                parsed.map do |unit|
                  send(:"for_#{unit.etype}", unit) # rescue raise UnsupportedRegularExpression
                end.join(' and ')
              end
            )
          end

          def insert_expr(conditions)
            count = (conditions.length - conditions.gsub('%s','').size) / 2
            conditions % ([expr]*count)
          end

          def for_string(entry)
            val = qc(entry.expanded_value, !entry.casefold?)
            expr, texpr = '%s', t('%s', !entry.casefold?)

            if entry.start_of_line? && entry.end_of_line?
              '%s=%s' % [texpr, val]
            elsif entry.start_of_line?
              'starts-with(%s,%s)' % [texpr, val]
            elsif entry.end_of_line?
              'substring(%s,string-length(%s)+1-string-length(%s))=%s' % [texpr, expr, val, val]
            else
              'contains(%s,%s)' % [texpr, val]
            end
          end

          def for_chars_set(entry)
            translate_from = entry.expanded_value
            compare_against = translate_from[0..0]
            translate_to = compare_against * translate_from.size

            if entry.casefold?
              translate_from = (translate_from.downcase + translate_from.upcase).split('').uniq.sort.join('')
              compare_against = translate_from[0..0]
              translate_to = compare_against * translate_from.size
            end

            expr = 'translate(%s,%s,%s)' % ['%s', q(translate_from), q(translate_to)]
            val = q(compare_against)

            if entry.start_of_line? && entry.end_of_line?
              '%s=%s' % [expr, val]
            elsif entry.start_of_line?
              'starts-with(%s,%s)' % [expr, val]
            elsif entry.end_of_line?
              'substring(%s,string-length(%s))=%s' % [expr, self.expr, val]
            else
              'contains(%s,%s)' % [expr, val]
            end
          end

          def q(str)
            String.quote(str)
          end

          def c(str, case_sensitive)
            case_sensitive ? str : str.downcase
          end

          def t(expr, case_sensitive)
            String.translate_casing(expr, case_sensitive)
          end

          def qc(str, case_sensitive=true)
            c(q(str), case_sensitive)
          end

        end

    end

  end
end
