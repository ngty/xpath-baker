require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'spec_helpers')
require 'xpb/html'

describe "XPB::HTML::Matchers::TD::Hash" do

  before do
    XPB.configure(:reset) do |config|
      config.normalize_space = false
      config.case_sensitive = true
      config.axial_node = :self
      config.match_ordering = false
    end
    @condition_should_equal = lambda do |config, expected|
      XPB::HTML::Matchers::TD::Hash.new(@values, XPB::Configuration.new(config)).
        condition.should.equal(expected)
    end
  end

  after do
    XPB.configure(:reset)
  end

  describe '> generating condition (for string values)' do

    extend XPB::Spec::Helpers::TD

    before do
      @values = {'#' => '1', 'Name' => 'John Tan'}
      @default = './td[%s]/../td[%s]' % @values.map do |field, val|
        comparison = lambda{|v| string_comparison(content_exprs, v) }
        th = %|ancestor::table[1]//th[%s][1]| % comparison[field]
        'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val]]
      end
    end

    should 'return expr reflecting specified config[:normalize_space]' do
      {
        false => @default,
        true => './td[%s]/../td[%s]' % @values.map do |field, val|
          comparison = lambda{|v| string_comparison(normalized_content_exprs, v) }
          th = %|ancestor::table[1]//th[%s][1]| % comparison[field]
          'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val]]
        end,
      }.each do |val, expected|
        @condition_should_equal[{:normalize_space => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:case_sensitive]' do
      {
        true => @default,
        false => './td[%s]/../td[%s]' % @values.map do |field, val|
          comparison = lambda{|v| string_comparison(translated_content_exprs, v) }
          th = %|ancestor::table[1]//th[%s][1]| % comparison[field.upcase]
          'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val.upcase]]
        end,
      }.each do |val, expected|
        @condition_should_equal[{:case_sensitive => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:axial_node]' do
      {
        :self => @default,
        :descendant => './td[%s]/../td[%s]' % @values.map do |field, val|
          comparison = lambda{|v| string_comparison(content_exprs, v) }
          th = %|ancestor::table[1]//th[descendant::*[%s]][1]| % comparison[field]
          'count(%s/preceding-sibling::th)+1][%s][descendant::*[%s]' % [th, th, comparison[val]]
        end
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
      }.each do |op, substr|
        expected = './td[%s]/../td[%s]' % @values.map do |field, val|
          th = %|ancestor::table[1]//th[%s][1]| % substr % ['text()', %|"#{field}"|, '.', %|"#{field}"|]
          'count(%s/preceding-sibling::th)+1][%s][%s' % [
            th, th, substr % ['text()', %|"#{val}"|, '.', %|"#{val}"|]
          ]
        end
        @condition_should_equal[{:comparison => op}, expected]
      end
    end

    valid_config_settings_args(
      :greedy, :include_inner_text, :scope, :position, :match_ordering,
      :element_matcher, :attribute_matcher, :text_matcher, :any_text_matcher,
      :literal_matcher, :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each do |config|
          @condition_should_equal[config, @default] if config.is_a?(Hash)
        end
      end
    end

  end

  describe '> generating condition (for array values)' do

    extend XPB::Spec::Helpers::TD

    before do
      @values = {%w{#} => %w{1}, %w{Full Name} => %w{John Tan}}
      @default = './td[%s]/../td[%s]' % @values.map do |field, val|
        comparison = lambda{|v| unsorted_token_comparison(content_exprs, v) }
        th = %|ancestor::table[1]//th[%s][1]| % comparison[field]
        'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val]]
      end
    end

    should 'return expr reflecting specified config[:normalize_space]' do
      {
        false => @default,
        true => './td[%s]/../td[%s]' % @values.map do |field, val|
          comparison = lambda{|v| unsorted_token_comparison(normalized_content_exprs, v) }
          th = %|ancestor::table[1]//th[%s][1]| % comparison[field]
          'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val]]
        end
      }.each do |val, expected|
        @condition_should_equal[{:normalize_space => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:case_sensitive]' do
      {
        true => @default,
        false => './td[%s]/../td[%s]' % @values.map do |field, val|
          comparison = lambda{|v| unsorted_token_comparison(translated_content_exprs, v.map(&:upcase)) }
          th = %|ancestor::table[1]//th[%s][1]| % comparison[field]
          'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val]]
        end
      }.each do |val, expected|
        @condition_should_equal[{:case_sensitive => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:match_ordering]' do
      {
        false => @default,
        true => './td[%s]/../td[%s]' % @values.map do |field, val|
          comparison = lambda{|v| sorted_token_comparison(content_exprs, v) }
          th = %|ancestor::table[1]//th[%s][1]| % comparison[field]
          'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val]]
        end
      }.each do |val, expected|
        @condition_should_equal[{:match_ordering => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:axial_node]' do
      {
        :self => @default,
        :descendant => './td[%s]/../td[%s]' % @values.map do |field, val|
          comparison = lambda{|v| unsorted_token_comparison(content_exprs, v) }
          th = %|ancestor::table[1]//th[descendant::*[%s]][1]| % comparison[field]
          'count(%s/preceding-sibling::th)+1][%s][descendant::*[%s]' % [th, th, comparison[val]]
        end
      }.each do |axial_node, expected|
        @condition_should_equal[{:axial_node => axial_node}, expected]
      end
    end

    should "apply negation when config[:comparison] is any of: ! != !> !< !>= !<=" do
      expected = './td[%s]/../td[%s]' % @values.map do |field, val|
        comparison = lambda{|v| unsorted_token_comparison(content_exprs, v) }
        th = %|ancestor::table[1]//th[not(%s)][1]| % comparison[field]
        'count(%s/preceding-sibling::th)+1][%s][not(%s)' % [th, th, comparison[val]]
      end
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
      :element_matcher, :attribute_matcher, :text_matcher, :any_text_matcher,
      :literal_matcher, :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each do |config|
          @condition_should_equal[config, @default] if config.is_a?(Hash)
        end
      end
    end

  end

end
