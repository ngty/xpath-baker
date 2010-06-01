module XPathFu
  module PathBuilding

    protected

      LOWERCASE_CHARS = ('a'..'z').to_a * ''
      UPPERCASE_CHARS = ('A'..'Z').to_a * ''

      def build(element, *args, &blk)
        conditions = yield(parse_args(*args)).flatten.compact
        "#{scope}#{element}%s" % (conditions.empty? ? '' : "[#{conditions.join('][')}]")
      end

      def generic_attrs_conditions(attrs)
        attrs.map {|name, val| '%s=%s' % [c(n("@#{name}")), c(q(val))] }
      end

      def c(str)
        config.case_sensitive ? str :
          %\translate(#{str},"#{UPPERCASE_CHARS}","#{LOWERCASE_CHARS}")\
      end

      def q(str)
        !str.include?('"') ? %\"#{str}"\ :
          'concat(%s)' % str.split('"').map {|substr| %\"#{substr}"\ }.join(%\,'"',\)
      end

      def n(str)
        config.normalize_space ? %\normalize-space(#{str})\ : str
      end

      def t
        config.include_inner_text ? '.' : 'text()'
      end

  end
end
