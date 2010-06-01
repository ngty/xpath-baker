require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'xpathfu')
require 'xpathfu/html/tr'

module XPathFu

  declare_mode_as :html

  extend HTML::Tr

end
