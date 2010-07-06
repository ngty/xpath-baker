module XPF
  module Matchers
    module Values
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
    end
  end
end

