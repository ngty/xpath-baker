require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'spec_helpers')
require 'xpath-baker/html'

describe "XPathBaker::HTML::Matchers::TD::Nil" do

  before do
    XPathBaker.configure(:reset) do |config|
      config.normalize_space = false
      config.case_sensitive = true
      config.axial_node = :self
    end
    @condition_should_equal = lambda do |config, expected|
      XPathBaker::HTML::Matchers::TD::Nil.new('dummy', XPathBaker::Configuration.new(config)).
        condition.should.equal(expected)
    end
  end

  after do
    XPathBaker.configure(:reset)
  end

  describe '> generating condition' do

    before do
      @default = './td[(text()) or (.)]'
    end

    should 'return expr reflecting specified config[:normalize_space]' do
      {
        true => './td[(%s)]' % %w{text() .}.map{|e| %|normalize-space(#{e})| }.join(') or ('),
        false => @default
      }.each do |val, expected|
        @condition_should_equal[{:normalize_space => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:axial_node]' do
      {
        :self => @default,
        :descendant => './td[descendant::*[(text()) or (.)]]'
      }.each do |axial_node, expected|
        @condition_should_equal[{:axial_node => axial_node}, expected]
      end
    end

    should "apply negation when config[:comparison] is any of: ! != !> !< !>= !<=" do
      expected = './td[not((text()) or (.))]'
      %w{! != !> !>= !< !<=}.each do |op|
        @condition_should_equal[{:comparison => op}, expected]
      end
    end

    should 'apply equality when config[:comparison] is any of: = > >= < <=' do
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
