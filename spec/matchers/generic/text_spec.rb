require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'basic_text_shared_spec')

describe 'XPathBaker::Matchers::Text' do
  before { @text_matcher = XPathBaker::Matchers::Text }
  behaves_like 'a basic text matcher'
end
