require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'XPathFu::HTML' do

  describe "> requiring 'xpathfu/html'" do

    before do
      XPathFu.send(:remove_const, :MODE) if XPathFu.const_defined?(:MODE)
    end

    should 'raise XPathFu::ModeAlreadySpecifiedError when XPathFu::MODE is already declared' do
      XPathFu.const_set(:MODE, :another)
      lambda { require 'xpathfu/html' }.
        should.raise(XPathFu::ModeAlreadyDeclaredError).
        message.should.equal('Mode has already been declared as :another !!')
    end

    should 'set XPathFu::MODE as :html' do
      require 'xpathfu/html'
      XPathFu::MODE.should.equal :html
    end

  end

end
