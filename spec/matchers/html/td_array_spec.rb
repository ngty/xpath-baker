require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'spec_helpers')
require 'xpf/html'

describe "XPF::HTML::Matchers::TD::Array" do

  before do
    XPF.configure(:reset) do |config|
      config.normalize_space = false
      config.case_sensitive = true
      config.axial_node = :self
      config.match_ordering = false
    end
    @condition_should_equal = lambda do |config, expected|
      XPF::HTML::Matchers::TD::Array.new(@values, XPF::Configuration.new(config)).
        condition.should.equal(expected)
    end
  end

  after do
    XPF.configure(:reset)
  end

  describe '> generating condition (for string values)' do

    extend XPF::Spec::Helpers::TD

    before do
      @values = %w{AWE SOME}
      @default = './td[%s]/../td[%s]' % @values.map{|val| string_comparison(content_exprs, val) }
    end

    should 'return expr reflecting specified config[:normalize_space]' do
      {
        true => './td[%s]/../td[%s]' % @values.map{|val| string_comparison(normalized_content_exprs, val) },
        false => @default
      }.each do |val, expected|
        @condition_should_equal[{:normalize_space => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:case_sensitive]' do
      {
        false => './td[%s]/../td[%s]' %
          @values.map{|val| string_comparison(translated_content_exprs, val.upcase) },
        true => @default
      }.each do |val, expected|
        @condition_should_equal[{:case_sensitive => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:match_ordering]' do
      {
        true => './td[%s]/following-sibling::td[%s]' %
          @values.map{|val| string_comparison(content_exprs, val) },
        false => @default
      }.each do |val, expected|
        @condition_should_equal[{:match_ordering => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:axial_node]' do
      {
        :descendant => './td[descendant::*[%s]]/../td[descendant::*[%s]]' %
          @values.map{|val| string_comparison(content_exprs, val) },
        :self => @default
      }.each do |axial_node, expected|
        @condition_should_equal[{:axial_node => axial_node}, expected]
      end
    end

    should 'return expr reflecting specified config[:comparison]' do
      {
        '!'   => 'not((%s=%s) or (%s=%s))',
        '='   => '(%s=%s) or (%s=%s)',
        '!='  => 'not((%s=%s) or (%s=%s))',
        '>'   => '(%s>%s) or (%s>%s)',
        '!>'  => 'not((%s>%s) or (%s>%s))',
        '<'   => '(%s<%s) or (%s<%s)',
        '!<'  => 'not((%s<%s) or (%s<%s))',
        '>='   => '(%s>=%s) or (%s>=%s)',
        '!>='  => 'not((%s>=%s) or (%s>=%s))',
        '<='   => '(%s<=%s) or (%s<=%s)',
        '!<='  => 'not((%s<=%s) or (%s<=%s))',
      }.each do |op, expected|
        expected = './td[%s]/../td[%s]' %
          @values.map{|val| expected % ['text()', %|"#{val}"|, '.', %|"#{val}"|] }
        @condition_should_equal[{:comparison => op}, expected]
      end
    end

    valid_config_settings_args(
      :greedy, :include_inner_text, :scope, :position,
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

  describe '> generating condition (for array values)' do

    extend XPF::Spec::Helpers::TD

    before do
      @values = [%w{AWE SOME}, %w{WONDER}]
      @default = './td[%s]/../td[%s]' % @values.map{|val| unsorted_token_comparison(content_exprs, val) }
    end

    should 'return expr reflecting specified config[:normalize_space]' do
      {
        true => './td[%s]/../td[%s]' %
          @values.map{|val| unsorted_token_comparison(normalized_content_exprs, val) },
        false => @default
      }.each do |val, expected|
        @condition_should_equal[{:normalize_space => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:case_sensitive]' do
      {
        false => './td[%s]/../td[%s]' %
          @values.map{|val| unsorted_token_comparison(translated_content_exprs, val.map(&:upcase)) },
        true => @default
      }.each do |val, expected|
        @condition_should_equal[{:case_sensitive => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:match_ordering]' do
      {
        true => './td[%s]/following-sibling::td[%s]' %
          @values.map{|val| sorted_token_comparison(content_exprs, val) },
        false => @default
      }.each do |val, expected|
        @condition_should_equal[{:match_ordering => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:axial_node]' do
      {
        :descendant => './td[descendant::*[%s]]/../td[descendant::*[%s]]' %
          @values.map{|val| unsorted_token_comparison(content_exprs, val) },
        :self => @default,
      }.each do |axial_node, expected|
        @condition_should_equal[{:axial_node => axial_node}, expected]
      end
    end

    should "apply negation when config[:comparison] is any of: ! != !> !< !>= !<=" do
      expected = './td[not(%s)]/../td[not(%s)]' %
        @values.map{|val| unsorted_token_comparison(content_exprs, val) }
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
      :greedy, :include_inner_text, :scope, :position,
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
