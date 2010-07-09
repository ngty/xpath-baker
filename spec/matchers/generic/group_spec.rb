require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'basic_group_shared_spec')

describe "XPathBaker::Matchers::Group" do
  before { @matcher_klass = XPathBaker::Matchers::Group }
  behaves_like 'basic group matcher'
end
