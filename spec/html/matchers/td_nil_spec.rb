require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'xpf/html'

describe "XPF::HTML::Matchers::TD::Nil" do

  before do
    XPF.configure(:reset) do |config|
      config.normalize_space = true
      config.case_sensitive = true
      config.axial_node = :self
      config.match_ordering = true
    end
  end

  after do
    XPF.configure(:reset)
  end

  describe '> generating condition' do

    before do
      @default = 'child::td[(normalize-space(text())) or (normalize-space(.))]'
      @condition_should_equal = lambda do |config, expected|
        XPF::HTML::Matchers::TD::Nil.new('dummy', XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'return expr reflecting specified config[:normalize_space]' do
      @condition_should_equal[{:normalize_space => true}, @default]
      @condition_should_equal[{:normalize_space => false}, 'child::td[(text()) or (.)]']
    end

    should 'return expr reflecting specified config[:axial_node]' do
      {
        :self => @default,
        :descendant => 'child::td[descendant::*[(normalize-space(text())) or (normalize-space(.))]]'
      }.each do |axial_node, expected|
        @condition_should_equal[{:axial_node => axial_node}, expected]
      end
    end

    should "apply negation when config[:comparison] is any of: ! != !> !< !>= !<=" do
      expected = 'child::td[not((normalize-space(text())) or (normalize-space(.)))]'
      %w{! != !> !>= !< !<=}.each do |op|
        @condition_should_equal[{:comparison => op}, expected]
      end
    end

    should 'ignore all other specified config[:comparison]' do
      %w{= > >= < <=}.each do |op|
        @condition_should_equal[{:comparison => op}, @default]
      end
    end

    valid_config_settings_args(
      :greedy, :match_ordering, :case_sensitive, :include_inner_text, :scope, :position,
      :element_matcher, :attribute_matcher, :text_matcher, :any_text_matcher, :literal_matcher,
      :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each do |config|
          @condition_should_equal[config, @default] if config.is_a?(Hash)
        end
      end
    end

  end

end
