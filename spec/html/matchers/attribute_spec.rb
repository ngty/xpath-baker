require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'xpf', 'matchers', 'basic_attribute_shared_spec')
require 'xpf/html'

describe "XPF::HTML::Matchers::Attribute" do

  before { @attr_matcher = XPF::HTML::Matchers::Attribute }
  behaves_like 'basic attribute matcher'

end
