require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), 'arguments_data')

describe 'XPF::Arguments' do

  before do
    class << XPF::Arguments
      alias_method :orig_new_config, :new_config
      alias_method :orig_new_matcher, :new_matcher
      def new_config(config) ; config ; end
      def new_matcher(match_attrs, config)
        def (matcher = [match_attrs, config]).condition
          !self.first.empty? or nil
        end
        matcher
      end
    end
    @parse = lambda {|args| XPF::Arguments.parse(*args) }
    @parse_w_config = lambda {|args, config| XPF::Arguments.parse_with_config(args, config) }
  end

  after do
    class << XPF::Arguments
      alias_method :new_matcher, :orig_new_matcher
      alias_method :new_config, :orig_new_config
    end
  end

  normalize_config = lambda{|arg| XPF::Configuration.normalize(arg) }

  describe '> parsing (w zero args)' do

    before do
      @parsed_args = @parse[[]]
    end

    should 'return config as default' do
      @parsed_args.last.should.equal({})
    end

    should 'return zero matcher' do
      @parsed_args.first.should.be.empty
    end

  end

  describe '> parsing (w only a config arg)' do

    before do
      @config = {:position => 9}
      @parsed_args = @parse[[@config]]
    end

    should 'return config as specified' do
      @parsed_args.last.should.equal(@config)
    end

    should 'return zero matcher' do
      @parsed_args.first.should.be.empty
    end

  end

  [{:position => 9, :scope => '//awe/some/'}, %w{9 //awe/some/}, [], {}].each do |common_config|
    xpf_valid_permutated_arguments.each do |args, expected|

      describe "> parsing valid args %s" % (
        common_config.empty? ? args.map(&:inspect).join(', ') :
          [args.map(&:inspect).join(', '), common_config.inspect].join(', ')
        ) do

        before do
          @parsed_args = lambda{|i| @parse[args + (common_config.empty? ? [] : [common_config])][i] }
        end

        should "return config as specified" do
          @parsed_args[1].should.equal(normalize_config[common_config])
        end

        should "return matchers w configs as specified" do
          @parsed_args[0].map(&:last).should.equal(
            expected[1].map{|c| normalize_config[common_config].merge(normalize_config[c]) }
          )
        end

        should "return matchers w match attrs as specified" do
          @parsed_args[0].map(&:first).should.equal(expected[0])
        end

      end
    end
  end

  {'w'  => {:position => 9}, 'wo' => {}}.each do |mode, default_config|
    describe "> parsing invalid args (#{mode} custom default config)" do
      xpf_invalid_permutated_arguments.each do |args|

        should "raise XPF::InvalidArgumentError w #{args.inspect}" do
          lambda { @parse[args + (default_config.empty? ? [] : [default_config])] }.
            should.raise(XPF::InvalidArgumentError).
            message.should.equal([
              'Expecting arguments to contain any permutations of the following fragments: ',
              ' (1) [{:attr1 => ..., ...}, {CONFIG}] and/or ',
              ' (2) [[:attr1, ...], {CONFIG}] and/or ',
              ' (3) {:attr1 => ..., ...} and/or ',
              ' (4) [:attr1, ...] and/or ',
              ' (5) {CONFIG} (*must be last if present)'
            ].join("\n"))
        end

      end
    end
  end

  describe '> parsing with config' do

    should 'parse with adding of config to args-specified config' do
      config = {:position => 9}
      @parse_w_config[[[:attr1]], config].first.map(&:last).should.equal([config])
    end

    should 'parse with args-specified config overriding that in config' do
      args_config, config = {:position => 8}, {:position => 9}
      @parse_w_config[[[:attr1], args_config], config].first.map(&:last).should.equal([args_config])
    end

    should 'not be affected by any previous parse' do
      previous, current = {:position => 9}, {}
      @parse_w_config[[[:attr1]], previous]
      @parse_w_config[[[:attr1]], current].first.map(&:last).should.equal([current])
    end

  end

end
