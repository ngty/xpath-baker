module HtmlTrSpecHelpers

  def contents_for(path)
    (@hdoc = Nokogiri::HTML(%\
      <html>
        <body>
          <table>
            <tr><th>#</th><th>Full <br/>Name</th><th>Gender</th></tr>
            <tr><td> 1</td><td>Jane <br/>Lee</td><td>Female</td></tr>
            <tr><td>2 </td><td>John <br/>Tan</td><td>Male</td></tr>
            <tr><td> 3 </td><td>Jim <br/>Ma</td><td>Male</td></tr>
          </table>
        </body>
      </html>
    \)).xpath(path).map(&:text)
  end

  def case_sensitive_and_normalized_space_and_full_inner_text_xpath_for(scope, cells)
    content_cond = lambda {|val| %\[normalize-space(.)="#{val}"]\ }
    "#{scope}tr[%s]" % (
      if cells.is_a?(Hash)
        cells.map do |field, val|
          th = %\./ancestor::table[1]//th[normalize-space(.)="#{field}"][1]\
          %\.//td[count(#{th}/preceding-sibling::th)+1][#{th}]#{content_cond[val]}\
        end.join('][')
      else
        './/td' + cells.map {|val| content_cond[val] }.join('/following-sibling::td')
      end
    )
  end

  def case_sensitive_and_unnormalized_space_and_full_inner_text_xpath_for(scope, cells)
    content_cond = lambda {|val| %\[.="#{val}"]\ }
    "#{scope}tr[%s]" % (
      if cells.is_a?(Hash)
        cells.map do |field, val|
          th = %\./ancestor::table[1]//th[.="#{field}"][1]\
          %\.//td[count(#{th}/preceding-sibling::th)+1][#{th}]#{content_cond[val]}\
        end.join('][')
      else
        './/td' + cells.map {|val| content_cond[val] }.join('/following-sibling::td')
      end
    )
  end

  def case_sensitive_and_normalized_space_and_direct_text_xpath_for(scope, cells)
    content_cond = lambda {|val| %\[normalize-space(text())="#{val}"]\ }
    "#{scope}tr[%s]" % (
      if cells.is_a?(Hash)
        cells.map do |field, val|
          th = %\./ancestor::table[1]//th[normalize-space(text())="#{field}"][1]\
          %\.//td[count(#{th}/preceding-sibling::th)+1][#{th}]#{content_cond[val]}\
        end.join('][')
      else
        './/td' + cells.map {|val| content_cond[val] }.join('/following-sibling::td')
      end
    )
  end

  def case_insensitive_and_normalized_space_and_full_inner_text_xpath_for(scope, cells)
    upper_chars, lower_chars = ['A'..'Z', 'a'..'z'].map {|r| r.to_a.join('') }
    translate = lambda {|s| %\translate(#{s},"#{upper_chars}","#{lower_chars}")\ }
    content_cond = lambda {|val| %\[#{translate['normalize-space(.)']}=#{translate[%\"#{val}"\]}]\ }
    "#{scope}tr[%s]" % (
      if cells.is_a?(Hash)
        cells.map do |field, val|
          th = %\./ancestor::table[1]//th[#{translate['normalize-space(.)']}=#{translate[%\"#{field}"\]}][1]\
          %\.//td[count(#{th}/preceding-sibling::th)+1][#{th}]#{content_cond[val]}\
        end.join('][')
      else
        './/td' + cells.map {|val| content_cond[val] }.join('/following-sibling::td')
      end
    )
  end

  def scoped_args(scope, args)
    scope ? args.unshift(scope) : args
  end

end
