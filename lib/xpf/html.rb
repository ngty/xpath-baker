require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'xpf')
require 'xpf/html/tr'
require 'xpf/html/matchers/attribute'

module XPF

  declare_mode_as :html

  configure do |config|
    config.attribute_matcher = XPF::HTML::Matchers::Attribute
  end

  extend HTML::Tr

end
