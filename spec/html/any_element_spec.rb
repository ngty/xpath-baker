require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'basic_element_shared_spec')

describe "XPF::HTML <xzy/> support" do
  before { @element = :xyz }
  behaves_like 'a basic element'
end
