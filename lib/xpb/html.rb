require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'xpb')
require 'xpb/html/matchers'

module XPB

  declare_mode_as :html

  declare_support_for \
    :tr    => {:group_matcher => HTML::Matchers::TR::Group}

end
