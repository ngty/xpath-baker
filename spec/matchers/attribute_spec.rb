require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'basic_node_shared_spec')

describe 'XPF::Matchers::Attribute' do
  before { @node_matcher, @name = XPF::Matchers::Attribute, :@attr1 }
  behaves_like 'basic node matcher'
end
