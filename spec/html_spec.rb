require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'XPF::HTML' do

  describe "> requiring 'xpf/html'" do

#    before do
#      XPF.send(:remove_const, :MODE) if XPF.const_defined?(:MODE)
#    end
#
#    should 'raise XPF::ModeAlreadySpecifiedError when XPF::MODE is already declared' do
#      XPF.const_set(:MODE, :another)
#      lambda { require 'xpf/html' }.
#        should.raise(XPF::ModeAlreadyDeclaredError).
#        message.should.equal('Mode has already been declared as :another !!')
#    end
#
    should 'set XPF::MODE as :html' do
      require 'xpf/html'
      XPF::MODE.should.equal :html
    end

  end

end
