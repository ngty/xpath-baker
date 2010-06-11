require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'basic_attribute_shared_spec')

describe 'XPF::Matchers::Attribute' do
  before { @attr_matcher = XPF::Matchers::Attribute }
  behaves_like 'basic attribute matcher'
end
