require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'xpf/html'

describe "XPF::HTML <table/> support" do

  # NOTE: These are all we need for 'a basic html element' shared spec.
  require File.join(File.dirname(__FILE__), 'basic_element_shared_spec')
  before { @element = :table }
  behaves_like 'a basic html element'

end
