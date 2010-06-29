require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'basic_group_shared_spec')

describe "XPF::Matchers::Group" do
  before { @matcher_klass = XPF::Matchers::Group }
  behaves_like 'basic group matcher'
end
