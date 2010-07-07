module XPF
  module Matchers
    module Values
      class Regexp < Value(:expr, :regexp) #:nodoc:

        def to_condition
          @parsed_regexp = Reginald.parse(regexp)
          @case_sensitive = !@parsed_regexp.casefold?
          @branching_entries = []
          @context = Context.new(expr, t(expr))

          if @parsed_regexp.literal?
            'contains(%s,%s)' % [@context, qc(@parsed_regexp.to_s)]
          else
            @parsed_regexp.map do |@entry|
              if @entry.branchable?
                @branching_entries << @entry ; nil
              else
                @branching_entries.empty? ?
                  send(:"for_#{@entry.etype}") : for_branching_entries
              end
            end.push(for_leftover_entries).compact.join(' and ')
          end
        end

        def for_string(entry = nil)
          texpr = @context.to_s
          expr = @context.first? ? s(@context.to_s) : texpr
          for_any(
            entry ||= @entry, expr, texpr,
            val = entry.expanded_value, qc(val)
          )
        end

        alias_method :for_char, :for_string

        def for_chars_set(entry = nil)
          entry ||= @entry
          translate_from = entry.expanded_value
          translate_to = translate_from[0..0] * translate_from.size
          compare_against = translate_from[0..0] * (entry.quantifier || 1)
          expr = @context.first? ? s(@context.to_s) : @context.to_s

          for_any(
            entry, expr,
            'translate(%s,%s,%s)' % [expr, q(translate_from), q(translate_to)],
            compare_against, qc(compare_against)
          )
        end

        def for_any(entry, expr, texpr, val, qval)
          context = @context.dup
          @context.append(texpr, qval)

          if (entry.start_of_line? || !context.first?) && entry.end_of_line?
            '%s=%s' % [texpr, qval]
          elsif !context.first? or entry.start_of_line?
            'starts-with(%s,%s)' % [texpr, qval]
          elsif entry.end_of_line?
            'substring(%s,string-length(%s)%s)=%s' %
              [texpr, expr, (diff = 1 - val.size).zero? ? nil : diff, qval]
          else
            'contains(%s,%s)' % [texpr, qval]
          end
        end

        def for_branching_entries(*args)
          if (entries = args[0]).nil?
            branching_entries, @branching_entries = @branching_entries.dup, []
            for_branching_entries(branching_entries)
          elsif entries[0]
            for_branching_entry(entries[0], entries[1..-1])
          elsif @entry
            send(:"for_#{@entry.etype}")
          end
        end

        def for_branching_entry(first, others)
          entries = (expanded_val = first.expanded_value).is_a?(Array) ?
            expanded_val.map{|val| Reginald::TmpEntry.new(first, val, 1) } :
            first.quantifier.to_a.map{|q| Reginald::TmpEntry.new(first, expanded_val, q) }
          conditions = entries.map do |_entry|
            orig_context = @context.dup
            condition = send(:"for_#{_entry.etype}", _entry)
            nested = for_branching_entries(others)
            @context = orig_context
            nested ? "(#{condition} and #{nested})" : condition
          end
          conditions.size > 1 ? ('(%s)' % conditions.join(' or ')) : conditions[0]
        end

        def for_leftover_entries
          @entry = nil
          for_branching_entries
        end

        def q(str)
          String.quote(str)
        end

        def c(str)
          @case_sensitive ? str : str.upcase
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

        class Context

          def initialize(base, tbase)
            @first = @tbase = tbase
            @base = base
          end

          def first?
            @first == @tbase
          end

          def append(expr, token)
            base, @base = @base && @base.dup, nil
            @tbase = %W{
              substring(
                #{@tbase},
                1 + string-length(#{base || @tbase}) - string-length(
                  substring-after(#{expr},#{token})
                )
              )
            }.join('')
          end

          def to_s
            @tbase
          end

        end

      end
    end
  end
end
