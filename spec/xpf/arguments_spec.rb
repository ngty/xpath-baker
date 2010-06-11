require File.join(File.dirname(__FILE__), '..', 'spec_helper')

def xpf_invalid_permutated_arguments
{
  '1~s'        => ['attr1'],
  '1~:'        => [:attr1],

  '2~ss'       => ['attr1', 'attr2'],
  '2~::'       => [:attr1, :attr2],

  '2~s[h,c]'   => ['attr1', [{:attr2 => 2}, {:position => 2}]],
  '2~:[h,c]'   => [:attr1, [{:attr2 => 2}, {:position => 2}]],
  '2~s[h]'     => ['attr1', [{:attr2 => 2}]],
  '2~:[h]'     => [:attr1, [{:attr2 => 2}]],
  '2~sh'       => ['attr1', {:attr2 => 2}],
  '2~:h'       => [:attr1, {:attr2 => 2}],
  '2~s[a,c]'   => ['attr1', [[:attr2], {:position => 2}]],
  '2~:[a,c]'   => [:attr1, [[:attr2], {:position => 2}]],
  '2~s[a]'     => ['attr1', [[:attr2]]],
  '2~:[a]'     => [:attr1, [[:attr2]]],
  '2~sa'       => ['attr1', [:attr2]],
  '2~:a'       => [:attr1, [:attr2]],

  '2~[h,c]s'   => [[{:attr2 => 2}, {:position => 2}], 'attr1'],
  '2~[h,c]:'   => [[{:attr2 => 2}, {:position => 2}], :attr1],
  '2~[h]s'     => [[{:attr2 => 2}], 'attr1'],
  '2~[h]:'     => [[{:attr2 => 2}], :attr1],
  '2~hs'       => [{:attr2 => 2}, 'attr1'],
  '2~h:'       => [{:attr2 => 2}, :attr1],
  '2~[a,c]s'   => [[[:attr2], {:position => 2}], 'attr1'],
  '2~[a,c]:'   => [[[:attr2], {:position => 2}], :attr],
  '2~[a]s'     => [[[:attr2]], 'attr1'],
  '2~[a]:'     => [[[:attr2]], :attr1],
  '2~as'       => [[:attr2], 'attr1'],
  '2~a:'       => [[:attr2], :attr1],
}
end

def xpf_valid_permutated_arguments
{
  '1~[h,c]'           => [[{:attr1 => 1}, {:position => 1}]],
  '1~[a,c]'           => [[[:attr1], {:position => 1}]],
  '1~[h]'             => [[{:attr1 => 1}]],
  '1~[a]'             => [[[:attr1]]],
  '1~a'               => [[:attr1]],
  '1~h'               => [{:attr1 => 1}],

  '2~[h,c][h,c]'      => [[{:attr1 => 1}, {:position => 1}], [{:attr2 => 2}, {:position => 2}]],
  '2~[a,c][h,c]'      => [[[:attr1], {:position => 1}], [{:attr2 => 2}, {:position => 2}]],
  '2~[h,c][a,c]'      => [[{:attr1 => 1}, {:position => 1}], [[:attr2], {:position => 2}]],

  '2~[h][h,c]'        => [[{:attr1 => 1}], [{:attr2 => 2}, {:position => 2}]],
  '2~[a][h,c]'        => [[[:attr1]], [{:attr2 => 2}, {:position => 2}]],
  '2~[h][a,c]'        => [[{:attr1 => 1}], [[:attr2], {:position => 2}]],

  '2~[h,c][h]'        => [[{:attr1 => 1}, {:position => 1}], [{:attr2 => 2}]],
  '2~[a,c][h]'        => [[[:attr1], {:position => 1}], [{:attr2 => 2}]],
  '2~[h,c][a]'        => [[{:attr1 => 1}, {:position => 1}], [[:attr2]]],

  '2~a[h,c]'          => [[:attr1], [{:attr2 => 2}, {:position => 2}]],
  '2~[h,c]a'          => [[{:attr1 => 1}, {:position => 1}], [:attr2]],
  '2~a[h]'            => [[:attr1], [{:attr2 => 2}]],
  '2~[h]a'            => [[{:attr1 => 1}], [:attr2]],
  '2~ah'              => [[:attr1], {:attr2 => 2}],
  '2~ha'              => [{:attr1 => 1}, [:attr2]],

  # Well, the followings are actually not needed, but anyway, since they are done,
  # and specs run fast, we just leave them around (to be safe, i guess).
  '3~[h,c][h,c][h,c]' => [[{:attr1 => 1}, {:position => 1}], [{:attr2 => 2}, {:position => 2}], [{:attr3 => 3}, {:position => 3}]],
  '3~[a,c][a,c][a,c]' => [[[:attr1], {:position => 1}], [[:attr2], {:position => 2}], [[:attr3], {:position => 3}]],
  '3~[a,c][h,c][h,c]' => [[[:attr1], {:position => 1}], [{:attr2 => 2}, {:position => 2}], [{:attr3 => 3}, {:position => 3}]],
  '3~[h,c][a,c][h,c]' => [[{:attr1 => 1}, {:position => 1}], [[:attr2], {:position => 2}], [{:attr3 => 3}, {:position => 3}]],
  '3~[h,c][h,c][a,c]' => [[{:attr1 => 1}, {:position => 1}], [{:attr2 => 2}, {:position => 2}], [[:attr3], {:position => 3}]],

  '3~[h][h,c][h,c]'   => [[{:attr1 => 1}], [{:attr2 => 2}, {:position => 2}], [{:attr3 => 3}, {:position => 3}]],
  '3~[a][a,c][a,c]'   => [[[:attr1]], [[:attr2], {:position => 2}], [[:attr3], {:position => 3}]],
  '3~[a][h,c][h,c]'   => [[[:attr1]], [{:attr2 => 2}, {:position => 2}], [{:attr3 => 3}, {:position => 3}]],
  '3~[h][a,c][h,c]'   => [[{:attr1 => 1}], [[:attr2], {:position => 2}], [{:attr3 => 3}, {:position => 3}]],
  '3~[h][h,c][a,c]'   => [[{:attr1 => 1}], [{:attr2 => 2}, {:position => 2}], [[:attr3], {:position => 3}]],

  '3~h[h,c][h,c]'     => [{:attr1 => 1}, [{:attr2 => 2}, {:position => 2}], [{:attr3 => 3}, {:position => 3}]],
  '3~a[a,c][a,c]'     => [[:attr1], [[:attr2], {:position => 2}], [[:attr3], {:position => 3}]],
  '3~a[h,c][h,c]'     => [[:attr1], [{:attr2 => 2}, {:position => 2}], [{:attr3 => 3}, {:position => 3}]],
  '3~h[a,c][h,c]'     => [{:attr1 => 1}, [[:attr2], {:position => 2}], [{:attr3 => 3}, {:position => 3}]],
  '3~h[h,c][a,c]'     => [{:attr1 => 1}, [{:attr2 => 2}, {:position => 2}], [[:attr3], {:position => 3}]],

  '3~[h,c][h][h,c]'   => [[{:attr1 => 1}, {:position => 1}], [{:attr2 => 2}], [{:attr3 => 3}, {:position => 3}]],
  '3~[a,c][a][a,c]'   => [[[:attr1], {:position => 1}], [[:attr2]], [[:attr3], {:position => 3}]],
  '3~[a,c][h][h,c]'   => [[[:attr1], {:position => 1}], [{:attr2 => 2}], [{:attr3 => 3}, {:position => 3}]],
  '3~[h,c][a][h,c]'   => [[{:attr1 => 1}, {:position => 1}], [[:attr2]], [{:attr3 => 3}, {:position => 3}]],
  '3~[h,c][h][a,c]'   => [[{:attr1 => 1}, {:position => 1}], [{:attr2 => 2}], [[:attr3], {:position => 3}]],

  '3~[h,c]h[h,c]'     => [[{:attr1 => 1}, {:position => 1}], {:attr2 => 2}, [{:attr3 => 3}, {:position => 3}]],
  '3~[a,c]a[a,c]'     => [[[:attr1], {:position => 1}], [:attr2], [[:attr3], {:position => 3}]],
  '3~[a,c]h[h,c]'     => [[[:attr1], {:position => 1}], {:attr2 => 2}, [{:attr3 => 3}, {:position => 3}]],
  '3~[h,c]a[h,c]'     => [[{:attr1 => 1}, {:position => 1}], [:attr2], [{:attr3 => 3}, {:position => 3}]],
  '3~[h,c]h[a,c]'     => [[{:attr1 => 1}, {:position => 1}], {:attr2 => 2}, [[:attr3], {:position => 3}]],

  '3~[h,c][h,c][h]'   => [[{:attr1 => 1}, {:position => 1}], [{:attr2 => 2}, {:position => 2}], [{:attr3 => 3}]],
  '3~[a,c][a,c][a]'   => [[[:attr1], {:position => 1}], [[:attr2], {:position => 2}], [[:attr3]]],
  '3~[a,c][h,c][h]'   => [[[:attr1], {:position => 1}], [{:attr2 => 2}, {:position => 2}], [{:attr3 => 3}]],
  '3~[h,c][a,c][h]'   => [[{:attr1 => 1}, {:position => 1}], [[:attr2], {:position => 2}], [{:attr3 => 3}]],
  '3~[h,c][h,c][a]'   => [[{:attr1 => 1}, {:position => 1}], [{:attr2 => 2}, {:position => 2}], [[:attr3]]],

  '3~[h,c][h,c]h'     => [[{:attr1 => 1}, {:position => 1}], [{:attr2 => 2}, {:position => 2}], {:attr3 => 3}],
  '3~[a,c][a,c]a'     => [[[:attr1], {:position => 1}], [[:attr2], {:position => 2}], [:attr3]],
  '3~[a,c][h,c]h'     => [[[:attr1], {:position => 1}], [{:attr2 => 2}, {:position => 2}], {:attr3 => 3}],
  '3~[h,c][a,c]h'     => [[{:attr1 => 1}, {:position => 1}], [[:attr2], {:position => 2}], {:attr3 => 3}],
  '3~[h,c][h,c]a'     => [[{:attr1 => 1}, {:position => 1}], [{:attr2 => 2}, {:position => 2}], [:attr3]],
}
end

describe 'XPF::Arguments' do

  before do
    class << XPF::Arguments
      alias_method :orig_new_matcher, :new_matcher
      def new_matcher(match_attrs, config) ; [match_attrs, config] ; end
      def new_config(config) ; config ; end
    end
    @parse = lambda {|args| XPF::Arguments.parse(*args) }
  end

  after do
    class << XPF::Arguments
      alias_method :new_matcher, :orig_new_matcher
    end
  end

  describe '> parsing (w zero args)' do

    before do
      @parsed_args = @parse[[]]
    end

    should 'return config as default' do
      @parsed_args.last.should.equal({})
    end

    should 'return matcher w config as default' do
      @parsed_args.first.map(&:last).should.equal([{}])
    end

    should 'return matcher w match attrs as empty' do
      @parsed_args.first.map(&:first).should.equal([{}])
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

    should 'return matcher w config as specified' do
      @parsed_args.first.map(&:last).should.equal([@config])
    end

    should 'return matcher w match attrs as empty' do
      @parsed_args.first.map(&:first).should.equal([{}])
    end

  end

  {'w'  => {:position => 9}, 'wo' => {}}.each do |mode, default_config|
    describe "> parsing valid args (#{mode} custom default config)" do
      xpf_valid_permutated_arguments.each do |type, args|

        should "return config as specified ... \##{type}" do
          @parse[args + (default_config.empty? ? [] : [default_config])].last.
            should.equal(default_config)
        end

        should "return matchers w configs as specified ... \##{type}" do
          @parse[args + (default_config.empty? ? [] : [default_config])].first.map(&:last).should.
            equal(args.map{|arg| arg[1] || default_config })
        end

        should "return matchers w match attrs as specified ... \##{type}" do
          @parse[args + (default_config.empty? ? [] : [default_config])].first.map(&:first).should.
            equal(args.map{|arg| arg[0].is_a?(Hash) ? arg[0] : (arg[0].is_a?(Array) ? arg[0] : arg) })
        end

      end
    end
  end

  {'w'  => {:position => 9}, 'wo' => {}}.each do |mode, default_config|
    describe "> parsing invalid args (#{mode} custom default config)" do
      xpf_invalid_permutated_arguments.each do |type, args|

        should "raise XPF::InvalidArgumentError ... \##{type}" do
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

end
