require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe "XPF::Matchers::Literal" do

  describe '> generating condition' do

    before do
      @val, @default = ['wonder-fu']*2
      @condition_should_equal = lambda do |config, expected|
        XPF::Matchers::Literal.new(@val, XPF::Configuration.new(config)).condition.should.equal(expected)
      end
    end

    should 'return expr as it is' do
      @condition_should_equal[{}, @default]
    end

    valid_config_settings_args(
      :greedy, :match_ordering, :case_sensitive, :include_inner_text, :normalize_space,
      :comparison, :scope, :position, :axial_node, :element_matcher, :attribute_matcher,
      :text_matcher, :any_text_matcher, :literal_matcher, :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each{|config| @condition_should_equal[config, @default] }
      end
    end

  end

end
