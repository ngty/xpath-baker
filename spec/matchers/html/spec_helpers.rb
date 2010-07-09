module XPathBaker
  module Spec
    module Helpers

      module TD

        def token_comparison(exprs, vals, sorted)
          '(%s) or (%s)' % exprs.map{|e| check_tokens(e, vals.map{|val| %|"#{val}"| }, sorted) }
        end

        def unsorted_token_comparison(exprs, vals)
          token_comparison(exprs, vals, false)
        end

        def sorted_token_comparison(exprs, vals)
          token_comparison(exprs, vals, true)
        end

        def string_comparison(exprs, val)
          '(%s) or (%s)' % exprs.map{|e| %|#{e}="#{val}"| }
        end

        def normalized_content_exprs
          content_exprs.map{|e| "normalize-space(#{e})" }
        end

        def translated_content_exprs
          content_exprs.map{|e| translate_casing(e) }
        end

        def content_exprs
          %w{text() .}
        end

      end

    end
  end
end
