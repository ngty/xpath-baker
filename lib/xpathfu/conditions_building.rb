module XPathFu
  module ConditionsBuilding

    protected

      LOWERCASE_CHARS = ('a'..'z').to_a * ''
      UPPERCASE_CHARS = ('A'..'Z').to_a * ''

      def c(str)
        config.case_sensitive ? str :
          %\translate("#{UPPERCASE_CHARS}","#{LOWERCASE_CHARS}",#{str})\
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
