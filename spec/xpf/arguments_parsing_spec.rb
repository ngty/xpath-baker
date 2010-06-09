require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class << XPF
  public :parse_args
end

describe "XPF::ArgumentsParsing" do

  describe '> with :match_attrs & :config' do

    before do
      @match_attrs = {:attr1 => 'val1', :attr2 => 'val2'}
      @config = {:scope => '//watever'}
      @parse_args = lambda { XPF.parse_args(@match_attrs, @config) }
    end

    should 'return config as specified' do
      _, config = @parse_args[]
      config.scope.should.equal @config[:scope]
    end

    should 'return match attrs' do
      match_attrs, _ = @parse_args[]
      match_attrs.should.equal @match_attrs
    end

  end

  describe '> with :match_attrs' do

    before do
      @match_attrs = {:attr1 => 'val1', :attr2 => 'val2'}
      @parse_args = lambda { XPF.parse_args(@match_attrs) }
    end

    should 'return config as default' do
      _, config = @parse_args[]
      config.scope.should.equal XPF::Configuration.scope
    end

    should 'return match attrs' do
      match_attrs, _ = @parse_args[]
      match_attrs.should.equal @match_attrs
    end

  end

  describe '> with no args' do

    before do
      @parse_args = lambda { XPF.parse_args }
    end

    should 'return config as default' do
      _, config = @parse_args[]
      config.scope.should.equal XPF::Configuration.scope
    end

    should 'return match attrs' do
      match_attrs, _ = @parse_args[]
      match_attrs.should.equal({})
    end

  end

  describe '> with invalid args' do

    before do
      @message =
        'Expecting one of the following argument(s) group:, ' +
        '(1) match_attrs_hash & :config_hash, ' +
        '(2) match_attrs_hash, ' +
        '(3) (no args)'
    end

    should 'raise XPF::InvalidArgumentError when :match_attrs_hash is specified but not a Hash' do
      lambda { XPF.parse_args([], {}) }.
        should.raise(XPF::InvalidArgumentError).
        message.should.equal @message
    end

    should 'raise XPF::InvalidArgumentError when :config_hash is specified but not a Hash' do
      lambda { XPF.parse_args({}, []) }.
        should.raise(XPF::InvalidArgumentError).
        message.should.equal @message
    end

    should 'raise XPF::InvalidArgumentError when more than 2 args are specified' do
      lambda { XPF.parse_args({}, {}, nil) }.
        should.raise(XPF::InvalidArgumentError).
        message.should.equal @message
    end

  end

end
