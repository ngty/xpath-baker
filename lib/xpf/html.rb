require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'xpf')
require 'xpf/html/matchers'
require 'xpf/html/tr'
require 'xpf/html/table'

module XPF

  declare_mode_as :html

  extend HTML::Table
  extend HTML::TR

end
