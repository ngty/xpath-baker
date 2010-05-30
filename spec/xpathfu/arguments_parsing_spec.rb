require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class << XPathFu
  attr_writer :config
  public :parse_args, :config, :scope
end

describe "XPathFu::ArgumentsParsing" do

  describe '> with :scope, :match_attrs & :config' do

    before do
      @scope = '//aa/bb/'
      @match_attrs = {:attr1 => 'val1', :attr2 => 'val2'}
      @config = {:case_sensitive => 'aa'}
      @parse_args = lambda { XPathFu.parse_args(@scope, @match_attrs, @config) }
    end

    should 'set config as specified' do
      @parse_args[]
      XPathFu.config.case_sensitive.should.equal @config[:case_sensitive]
    end

    should 'set scope as specified' do
      @parse_args[]
      XPathFu.scope.should.equal @scope
    end

    should 'return match attrs' do
      @parse_args[].should.equal @match_attrs
    end

  end

  describe '> with :match_attrs & :config' do

    before do
      @match_attrs = {:attr1 => 'val1', :attr2 => 'val2'}
      @config = {:case_sensitive => 'aa'}
      @parse_args = lambda { XPathFu.parse_args(@match_attrs, @config) }
    end

    should 'set config as specified' do
      @parse_args[]
      XPathFu.config.case_sensitive.should.equal @config[:case_sensitive]
    end

    should "set scope as default '//'" do
      @parse_args[]
      XPathFu.scope.should.equal '//'
    end

    should 'return match attrs' do
      @parse_args[].should.equal @match_attrs
    end

  end

  describe '> with :scope & :match_attrs' do

    before do
      @match_attrs = {:attr1 => 'val1', :attr2 => 'val2'}
      @scope = '//aa/bb/'
      @parse_args = lambda { XPathFu.parse_args(@scope, @match_attrs) }
    end

    should 'set config as default' do
      @parse_args[]
      XPathFu.config.case_sensitive.should.equal true
    end

    should "set scope as specified" do
      @parse_args[]
      XPathFu.scope.should.equal @scope
    end

    should 'return match attrs' do
      @parse_args[].should.equal @match_attrs
    end

  end

  describe '> with :match_attrs' do

    before do
      @match_attrs = {:attr1 => 'val1', :attr2 => 'val2'}
      @parse_args = lambda { XPathFu.parse_args(@match_attrs) }
    end

    should 'set config as default' do
      @parse_args[]
      XPathFu.config.case_sensitive.should.equal true
    end

    should "set scope as default '//'" do
      @parse_args[]
      XPathFu.scope.should.equal '//'
    end

    should 'return match attrs' do
      @parse_args[].should.equal @match_attrs
    end

  end

  describe '> with invalid args' do

    before do
      @message =
        'Expecting one of the following argument(s) group:, ' +
        '(1) scope_str, match_attrs_hash & :config_hash, ' +
        '(2) match_attrs_hash & :config_hash, ' +
        '(3) match_attrs_hash'
    end

    should 'raise XPathFu::InvalidArgumentError with no arg specified' do
      lambda { XPathFu.parse_args }.
        should.raise(XPathFu::InvalidArgumentError).
        message.should.equal @message
    end

    should 'raise XPathFu::InvalidArgumentError with no match attrs hash specified' do
      lambda { XPathFu.parse_args('//aa/bb/') }.
        should.raise(XPathFu::InvalidArgumentError).
        message.should.equal @message
    end

  end

end
