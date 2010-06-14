module XPF
  module Matchers
    module Matchable #:nodoc:

      LOWERCASE_CHARS = ('a'..'z').to_a * ''
      UPPERCASE_CHARS = ('A'..'Z').to_a * ''
      NIL_VALUE = Struct.new('NIL_VALUE')

      def mv
        config.case_sensitive? ? q(value) : q(value.to_s.downcase)
      end

      def mt
        c(n(t))
      end

      def ma
        c(n(a))
      end

      def mc(conditions)
        ('self::*' == config.axis && conditions.empty?) ? nil :
          p('./%s' % config.axis, conditions.empty? ? nil : ('[%s]' % conditions.join('][')))
      end

      def p(axis, conditions)
        case (pos = config.position.to_s)
        when '' then '%s%s' % [axis, conditions]
        when /^\^/ then '%s[%s]%s' % [axis, pos.sub(/^\^/,''), conditions]
        else '%s%s[%s]' % [axis, conditions, pos.sub(/\$$/,'')]
        end
      end

      def a
        "@#{name}"
      end

      def c(str)
        config.case_sensitive ? str :
          %\translate(#{str},"#{UPPERCASE_CHARS}","#{LOWERCASE_CHARS}")\
      end

      def q(str)
        !str.include?('"') ? %\"#{str}"\ : (
          'concat(%s)' % str.split('"',-1).map {|s| %\"#{s}"\ }.join(%\,'"',\)
        )
      end

      def n(str)
        config.normalize_space ? %\normalize-space(#{str})\ : str
      end

      def t
        config.include_inner_text ? '.' : 'text()'
      end

      def nil_value
        NIL_VALUE
      end

    end
  end
end
