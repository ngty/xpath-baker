module XPF
  module Matchers
    module Values
      class Regexp < Value(:expr, :regexp) #:nodoc:

        def to_condition
          @parsed_regexp = Reginald.parse(regexp)
          @case_sensitive = !@parsed_regexp.casefold?
          @branching_entries = []
          @context = Context.new(t(expr))

          if @parsed_regexp.literal?
            'contains(%s,%s)' % [@context, qc(@parsed_regexp.to_s)]
          else
            @parsed_regexp.map do |@entry|
              if @entry.branchable? or !@branching_entries.empty?
                @branching_entries << @entry ; nil
              elsif @branching_entries.empty?
                send(:"for_#{@entry.etype}")
              end
            end.push(for_leftover_entries).compact.join(' and ')
          end
        end

        def for_string(entry = nil)
          entry ||= @entry
          val = entry.expanded_value
          texpr = @context.to_s
          expr = @context.first? ? s(@context.to_s) : texpr
          for_any(entry, expr, texpr, val, qc(val))
        end

        alias_method :for_char, :for_string

        def for_chars_set(entry = nil)
          entry ||= @entry
          translate_from = entry.expanded_value
          translate_to = translate_from[0..0] * translate_from.size
          val = translate_from[0..0] * (entry.quantifier || 1)
          expr = @context.first? ? s(@context.to_s) : @context.to_s
          texpr = 'translate(%s,%s,%s)' % [expr, q(translate_from), q(translate_to)]
          for_any(entry, expr, texpr, val, qc(val))
        end

        def for_any(entry, expr, texpr, val, qval)
          context = @context.dup
          @context.append(texpr, val, qval)
          (
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
          ).sub(
            # NOTE: Trimming off extra processing that serves no purpose !!
            /^(.*?translate\(substring\()translate\((.*?),"#{String::LC}","#{String::UC}"\)(.*)$/,
            '\1\2\3'
          )
        end

        def for_leftover_entries(*args)
          if first = (entries = args[0] and entries[0])
            conditions = first.to_a.map do |entry|
              orig_context = @context.dup
              condition = send(:"for_#{entry.etype}", entry)
              nested = for_leftover_entries(entries[1..-1])
              @context = orig_context
              nested ? "(#{condition} and #{nested})" : condition
            end
            conditions.size > 1 ? ('(%s)' % conditions.join(' or ')) : conditions[0]
          elsif args.empty?
            branching_entries, @branching_entries = @branching_entries.dup, []
            for_leftover_entries(branching_entries)
          end
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

          def initialize(context)
            @first = @context = context
          end

          def first?
            @first == @context
          end

          def to_s
            @context
          end

          def append(expr, token, qtoken)
            first? ? append_as_first(expr, qtoken) : append_as_other(token)
          end

          def append_as_first(expr, token)
            context = String.undo_translate_casing(@context)
            @context = %W{
              substring(
                #{@context},
                1 + string-length(#{context}) - string-length(
                  substring-after(#{expr},#{token})
                )
              )
            }.join('')
          end

          def append_as_other(token)
            @context = %|substring(#{@context},#{token.length.succ})|
          end

        end

      end
    end
  end
end
