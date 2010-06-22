require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "XPF::Matchers::Literal" do

  describe '> generating condition' do
    should 'return expr as it is' do
      XPF::Matchers::Literal.new(expr = 'wonder-fu').condition.should.equal(expr)
    end
  end

end
