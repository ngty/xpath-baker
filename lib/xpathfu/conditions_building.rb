module XPathFu
  module ConditionsBuilding

    protected

      LOWERCASE_CHARS = ('a'..'z').to_a * ''
      UPPERCASE_CHARS = ('A'..'Z').to_a * ''

      def t(str)
        config.case_sensitive ? str :
          %\translate("#{UPPERCASE_CHARS}","#{LOWERCASE_CHARS}",#{str})\
      end

      def q(str)
        !str.include?('"') ? %\"#{str}"\ :
          'concat(%s)' % str.split('"').map {|substr| %\"#{substr}"\ }.join(%\,'"',\)
      end

  end
end
