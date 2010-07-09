require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'XPB::HTML' do

  describe "> requiring 'xpb/html'" do

#    before do
#      XPB.send(:remove_const, :MODE) if XPB.const_defined?(:MODE)
#    end
#
#    should 'raise XPB::ModeAlreadySpecifiedError when XPB::MODE is already declared' do
#      XPB.const_set(:MODE, :another)
#      lambda { require 'xpb/html' }.
#        should.raise(XPB::ModeAlreadyDeclaredError).
#        message.should.equal('Mode has already been declared as :another !!')
#    end
#
    should 'set XPB::MODE as :html' do
      require 'xpb/html'
      XPB::MODE.should.equal :html
    end

  end

end
