module XPB
  module Matchers
    module Matchable

      class << (NIL_VALUE = Struct.new('NIL_VALUE'))
        def to_s ; 'XPB_NIL_VALUE' ; end
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
          q(config.case_sensitive? ? val : val.to_s.upcase)
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
          Values::String.translate_casing(str, config.case_sensitive?)
        end

        def q(str) #:nodoc:
          Values::String.quote("#{str}")
        end

        def n(str) #:nodoc:
          config.normalize_space? ? %\normalize-space(#{str})\ : "#{str}"
        end

        def t(expr, tokens) #:nodoc:
          (config.match_ordering? ? Values::SortedArray : Values::UnsortedArray).
            new(expr, tokens).to_condition
        end

        def r(expr, regexp) #:nodoc:
          Values::Regexp.new(expr, regexp).to_condition
        end

    end

  end
end
