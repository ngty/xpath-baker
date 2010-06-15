require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'xpf')
require 'xpf/html/tr'

module XPF

  declare_mode_as :html

  extend HTML::TR

end
