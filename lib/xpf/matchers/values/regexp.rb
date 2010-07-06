module XPF
  module Matchers
    module Values
      class Regexp < Value(:expr, :regexp) #:nodoc:

        def to_condition
          @previous_match_tokens = nil
          @delayed_match_entries = []
          expression = Reginald.parse(regexp)
          @case_sensitive = !expression.casefold?
          insert_expr(
            if expression.literal?
              'contains(%s,%s)' % [t('%s'), qc(expression.to_s)]
            else
              conditions = expression.map{|unit| send(:"for_#{unit.etype}", unit) }
              conditions << for_any_w_delayed_entries(nil) unless @delayed_match_entries.empty?
              conditions.compact.join(' and ')
            end
          )
        end

        def insert_expr(conditions)
          count = (conditions.length - conditions.gsub('%s','').size) / 2
          conditions % ([expr]*count)
        end

        def for_chars_set(entry)
          translate_from = entry.expanded_value
          compare_against = translate_from[0..0]
          translate_to = compare_against * translate_from.size
          flags = {:start => entry.start_of_line?, :end => entry.end_of_line?}
          texpr = 'translate(%s,%s,%s)' % ['%s', q(translate_from), q(translate_to)]

          case (quantifier = entry.quantifier)
          when nil
            per_tokens_group_condition(texpr, expr, q(compare_against), compare_against, flags)
          when Range
            '(%s)' % quantifier.to_a.map do |count|
              _compare_against = compare_against * count
              per_tokens_group_condition(texpr, expr, q(_compare_against), _compare_against, flags)
            end.join(' or ')
          when Integer
            _compare_against = compare_against * 2
            per_tokens_group_condition(texpr, expr, q(_compare_against), _compare_against, flags)
          end
        end

        def for_char(entry)
          for_string(entry)
        end

        def for_string(entry)
          if entry.expanded_value.is_a?(Array)
            @delayed_match_entries << entry
            nil
          elsif @delayed_match_entries.empty?
            for_any_wo_delayed_entries(entry)
          else
            for_any_w_delayed_entries(entry)
          end
        end

        def for_any_wo_delayed_entries(entry)
          expr, texpr, val, qval, prev_tokens, curr_tokens = reset_and_grab_match_tokens(entry)
          if prev_tokens
            (entry.end_of_line? ? '%s=%s' : 'starts-with(%s,%s)') %
              ['substring-after(%s,%s)' % prev_tokens, qval]
          else
            per_tokens_group_condition(texpr, expr, qval, val, {
              :start => entry.start_of_line?, :end => entry.end_of_line?
            })
          end
        end

        def for_any_w_delayed_entries(entry)
          prev_tokens = reset_and_grab_match_tokens(entry)[4]
          delayed_entries = @delayed_match_entries.dup
          @delayed_match_entries = []
          for_any_chained_delayed_entries(
            prev_tokens ? ('substring-after(%s,%s)' % prev_tokens) : t('%s'),
            delayed_entries, entry
          )
        end

        def for_any_chained_delayed_entries(expr, entries, last_entry)
          if first_entry = entries[0]
            flags = {
              :start => first_entry.start_of_line? || expr.include?('substring-after('),
              :end => first_entry.end_of_line?
            }
            join_conditions(
              first_entry.expanded_value.map do |val|
                qval = qc(val)
                condition = per_tokens_group_condition(expr, s(expr), qval, val, flags)
                nested = for_any_chained_delayed_entries(
                  'substring-after(%s,%s)' % [expr, qval],
                  entries[1..-1], last_entry
                )
                nested ? "(#{condition} and #{nested})" : condition
              end
            )
          elsif last_entry
            per_tokens_group_condition(
              expr, s(expr), qc(val = last_entry.expanded_value), val,
              :end => last_entry.end_of_line?, :start => true
            )
          end
        end

        def join_conditions(conditions, join=' or ')
          if conditions.size > 1
            '(%s)' % conditions.join(join)
          else
            conditions[0]
          end
        end

        def per_tokens_group_condition(texpr, expr, qval, val, flags)
          if flags[:start] && flags[:end]
            '%s=%s' % [texpr, qval]
          elsif flags[:start]
            'starts-with(%s,%s)' % [texpr, qval]
          elsif flags[:end]
            diff = 1 - val.size
            'substring(%s,string-length(%s)%s)=%s' %
              [texpr, expr, diff.zero? ? nil : diff, qval]
          else
            'contains(%s,%s)' % [texpr, qval]
          end
        end

        def reset_and_grab_match_tokens(entry)
          prev_tokens = @previous_match_tokens.dup rescue nil
          if entry
            val, expr = entry.expanded_value, '%s'
            qval, texpr = qc(val), t(expr)
            @previous_match_tokens = curr_tokens = [texpr, qval]
            [expr, texpr, val, qval, prev_tokens, curr_tokens]
          else
            [nil, nil, nil, nil, prev_tokens, [nil,nil]]
          end
        end

        def q(str)
          String.quote(str)
        end

        def c(str)
          @case_sensitive ? str : str.downcase
        end

        def t(expr)
          String.translate_casing(expr, @case_sensitive)
        end

        def s(expr)
          expr.sub(
            /^(.*)translate\((.*?),"#{String::UPPERCASE_CHARS}","#{String::LOWERCASE_CHARS}"\)(.*)$/,
            '\1\2\3'
          )
        end

        def qc(str)
          c(q(str))
        end

      end
    end
  end
end
