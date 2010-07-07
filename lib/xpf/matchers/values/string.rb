module XPF
  module Matchers
    module Values
      module String #:nodoc:

        LC = LOWERCASE_CHARS = ('a'..'z').to_a * ''
        UC = UPPERCASE_CHARS = ('A'..'Z').to_a * ''

        class << self

          def translate_casing(str, case_sensitive)
            (case_sensitive or str =~ /translate\((.*?),"#{LC}","#{UC}"\)/) ?
              str : %|translate(#{str},"#{LC}","#{UC}")|
          end

          def undo_translate_casing(str)
            str.sub(/^(.*)translate\((.*?),"#{LC}","#{UC}"\)(.*)$/, '\1\2\3')
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

