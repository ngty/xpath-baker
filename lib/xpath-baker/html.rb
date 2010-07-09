require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'xpath-baker')
require 'xpath-baker/html/matchers'

module XPathBaker

  declare_mode_as :html

  declare_support_for \
    :tr    => {:group_matcher => HTML::Matchers::TR::Group}

end
