require File.join(File.dirname(__FILE__), '..', 'spec_helper')

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

    should 'return single matcher w config as default' do
      @parsed_args.map(&:last).should.equal([{}])
    end

    should 'return single matcher w match attrs as empty' do
      @parsed_args.map(&:first).should.equal([{}])
    end

  end

  {'w'  => {:position => 9}, 'wo' => {}}.each do |mode, default_config|
    describe "> parsing (#{mode} custom default config)" do

      before do
        @parsed_args_should_have_expected_config = lambda do |args|
          @parse[args + (default_config.empty? ? [] : [default_config])].map(&:last).should.
            equal(args.map{|arg| arg[1] || default_config })
        end
        @parsed_args_should_have_expected_match_attrs = lambda do |args|
          @parse[args + (default_config.empty? ? [] : [default_config])].map(&:first).should.
            equal(args.map{|arg| arg[0].is_a?(Hash) ? arg[0] : (arg[0].is_a?(Array) ? arg[0] : arg) })
        end
      end

      xpf_valid_permutated_arguments.each do |type, args|
        should "return multiple matchers w configs as specified ... \##{type}" do
          @parsed_args_should_have_expected_config[args]
        end
        should "return multiple matchers w match attrs as specified ... \##{type}" do
          @parsed_args_should_have_expected_match_attrs[args]
        end
      end

    end
  end

end
