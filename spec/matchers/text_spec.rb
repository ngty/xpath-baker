require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'basic_text_shared_spec')

describe 'XPF::Matchers::Text' do
  before { @text_matcher = XPF::Matchers::Text }
  behaves_like 'a basic text matcher'
end
