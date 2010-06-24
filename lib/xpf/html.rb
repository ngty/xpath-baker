require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'xpf')
require 'xpf/html/matchers'

module XPF

  declare_mode_as :html

  declare_support_for \
    :tr    => {:group_matcher => HTML::Matchers::TR::Group}

end
