require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'XPathBaker::HTML' do

  describe "> requiring 'xpath-baker/html'" do

#    before do
#      XPathBaker.send(:remove_const, :MODE) if XPathBaker.const_defined?(:MODE)
#    end
#
#    should 'raise XPathBaker::ModeAlreadySpecifiedError when XPathBaker::MODE is already declared' do
#      XPathBaker.const_set(:MODE, :another)
#      lambda { require 'xpath-baker/html' }.
#        should.raise(XPathBaker::ModeAlreadyDeclaredError).
#        message.should.equal('Mode has already been declared as :another !!')
#    end
#
    should 'set XPathBaker::MODE as :html' do
      require 'xpath-baker/html'
      XPathBaker::MODE.should.equal :html
    end

  end

end
