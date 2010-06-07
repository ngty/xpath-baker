require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class << XPF
  attr_writer :config
  public :parse_args, :config, :scope
end

describe "XPF::ArgumentsParsing" do

  describe '> with :scope, :match_attrs & :config' do

    before do
      @scope = '//aa/bb/'
      @match_attrs = {:attr1 => 'val1', :attr2 => 'val2'}
      @config = {:case_sensitive => 'aa'}
      @parse_args = lambda { XPF.parse_args(@scope, @match_attrs, @config) }
    end

    should 'set config as specified' do
      @parse_args[]
      XPF.config.case_sensitive.should.equal @config[:case_sensitive]
    end

    should 'set scope as specified' do
      @parse_args[]
      XPF.scope.should.equal @scope
    end

    should 'return match attrs' do
      @parse_args[].should.equal @match_attrs
    end

  end

  describe '> with :match_attrs & :config' do

    before do
      @match_attrs = {:attr1 => 'val1', :attr2 => 'val2'}
      @config = {:case_sensitive => 'aa'}
      @parse_args = lambda { XPF.parse_args(@match_attrs, @config) }
    end

    should 'set config as specified' do
      @parse_args[]
      XPF.config.case_sensitive.should.equal @config[:case_sensitive]
    end

    should "set scope as default '//'" do
      @parse_args[]
      XPF.scope.should.equal '//'
    end

    should 'return match attrs' do
      @parse_args[].should.equal @match_attrs
    end

  end

  describe '> with :scope & :match_attrs' do

    before do
      @match_attrs = {:attr1 => 'val1', :attr2 => 'val2'}
      @scope = '//aa/bb/'
      @parse_args = lambda { XPF.parse_args(@scope, @match_attrs) }
    end

    should 'set config as default' do
      @parse_args[]
      XPF.config.case_sensitive.should.equal true
    end

    should "set scope as specified" do
      @parse_args[]
      XPF.scope.should.equal @scope
    end

    should 'return match attrs' do
      @parse_args[].should.equal @match_attrs
    end

  end

  describe '> with :match_attrs' do

    before do
      @match_attrs = {:attr1 => 'val1', :attr2 => 'val2'}
      @parse_args = lambda { XPF.parse_args(@match_attrs) }
    end

    should 'set config as default' do
      @parse_args[]
      XPF.config.case_sensitive.should.equal true
    end

    should "set scope as default '//'" do
      @parse_args[]
      XPF.scope.should.equal '//'
    end

    should 'return match attrs' do
      @parse_args[].should.equal @match_attrs
    end

  end

  describe '> with :scope' do

    before do
      @scope = '//aa/bb/'
      @parse_args = lambda { XPF.parse_args(@scope) }
    end

    should 'set config as default' do
      @parse_args[]
      XPF.config.case_sensitive.should.equal true
    end

    should "set scope as specified" do
      @parse_args[]
      XPF.scope.should.equal @scope
    end

    should 'return match attrs' do
      @parse_args[].should.equal({})
    end

  end

  describe '> with no args' do

    before do
      @parse_args = lambda { XPF.parse_args }
    end

    should 'set config as default' do
      @parse_args[]
      XPF.config.case_sensitive.should.equal true
    end

    should "set scope as specified" do
      @parse_args[]
      XPF.scope.should.equal '//'
    end

    should 'return match attrs' do
      @parse_args[].should.equal({})
    end

  end

  describe '> with invalid args' do

    before do
      @message =
        'Expecting one of the following argument(s) group:, ' +
        '(1) scope_str, match_attrs_hash & :config_hash, ' +
        '(2) match_attrs_hash & :config_hash, ' +
        '(3) match_attrs_hash, ' +
        '(4) scope_str, ' +
        '(5) (no args)'
    end

    should 'raise XPF::InvalidArgumentError when :match_attrs_hash is specified but not a Hash' do
      lambda { XPF.parse_args('//aa/bb/', [], {}) }.
        should.raise(XPF::InvalidArgumentError).
        message.should.equal @message
    end

    should 'raise XPF::InvalidArgumentError when :config_hash is specified but not a Hash' do
      lambda { XPF.parse_args('//aa/bb/', {}, []) }.
        should.raise(XPF::InvalidArgumentError).
        message.should.equal @message
    end

    should 'raise XPF::InvalidArgumentError when more than 3 args are specified' do
      lambda { XPF.parse_args('//aa/bb/', {}, {}, nil) }.
        should.raise(XPF::InvalidArgumentError).
        message.should.equal @message
    end

  end

end