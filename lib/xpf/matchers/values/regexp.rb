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
          case (count = entry.quantifier)
          when Range
            # TODO: WIP
            translate_from = entry.expanded_value
            compare_against = translate_from[0..0]
            translate_to = compare_against * translate_from.size
            texpr = 'translate(%s,%s,%s)' % [expr = '%s', q(translate_from), q(translate_to)]
            '(%s)' % count.to_a.map do |count|
              _compare_against = compare_against * count
              per_tokens_group_condition(texpr, expr, q(_compare_against), _compare_against, entry.flags)
            end.join(' or ')
          else
            expr, texpr, val, qval, prev_tokens, curr_tokens =
              reset_and_grab_match_tokens(entry) do |prev|
                translate_from = entry.expanded_value
                compare_against = translate_from[0..0] * (count || 1)
                translate_to = translate_from[0..0] * translate_from.size
                expr = prev ? ('substring-after(%s,%s)' % prev) : '%s'
                texpr = 'translate(%s,%s,%s)' % [expr, q(translate_from), q(translate_to)]
                [expr, texpr, compare_against, q(compare_against)]
              end
            per_tokens_group_condition(texpr, expr, qval, val, entry.flags)
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
          per_tokens_group_condition(texpr, expr, qval, val, entry.flags)
        end

        def for_any_w_delayed_entries(entry)
          texpr, _, _, prev_tokens = reset_and_grab_match_tokens(entry)[1..4]
          delayed_entries, @delayed_match_entries = @delayed_match_entries.dup, []
          for_any_chained_delayed_entries(texpr, delayed_entries, entry)
        end

        def for_any_chained_delayed_entries(expr, entries, last_entry)
          if first_entry = entries[0]
            join_conditions(
              first_entry.expanded_value.map do |val|
                qval = qc(val)
                condition = per_tokens_group_condition(expr, s(expr), qval, val, first_entry.flags)
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
              last_entry.flags.merge(:start_of_line => true)
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
          flags[:start_of_line] = true if expr.include?('substring-after(')
          if flags[:start_of_line] && flags[:end_of_line]
            '%s=%s' % [texpr, qval]
          elsif flags[:start_of_line]
            'starts-with(%s,%s)' % [texpr, qval]
          elsif flags[:end_of_line]
            diff = 1 - val.size
            'substring(%s,string-length(%s)%s)=%s' %
              [texpr, expr, diff.zero? ? nil : diff, qval]
          else
            'contains(%s,%s)' % [texpr, qval]
          end
        end

        def reset_and_grab_match_tokens(entry)
          prev_tokens = @previous_match_tokens.dup rescue nil
          if block_given?
            expr, texpr, val, qval = yield(prev_tokens)
            @previous_match_tokens = curr_tokens = [texpr, qval]
            [expr, texpr, val, qval, prev_tokens, curr_tokens]
          else
            expr = prev_tokens ? ('substring-after(%s,%s)' % prev_tokens) : '%s'
            texpr = t(expr)
            if entry
              val, qval = [val = entry.expanded_value, qc(val)]
              @previous_match_tokens = curr_tokens = [texpr, qval]
              [expr, texpr, val, qval, prev_tokens, curr_tokens]
            else
              [expr, texpr, nil, nil, prev_tokens, [nil,nil]]
            end
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
          String.undo_translate_casing(expr)
        end

        def qc(str)
          c(q(str))
        end

      end
    end
  end
end
