require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'basic_element_shared_spec')

describe "Any dynamically created element" do
  before { @element = :xyz }
  behaves_like 'a basic element'
end
