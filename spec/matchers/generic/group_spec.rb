require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'basic_group_shared_spec')

describe "XPB::Matchers::Group" do
  before { @matcher_klass = XPB::Matchers::Group }
  behaves_like 'basic group matcher'
end
