require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'basic_node_shared_spec')

describe 'XPB::Matchers::Attribute' do
  before { @node_matcher, @name = XPB::Matchers::Attribute, :@attr1 }
  behaves_like 'basic node matcher'
end
