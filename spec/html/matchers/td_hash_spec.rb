require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'xpf/html'

describe "XPF::HTML::Matchers::TD::Hash" do

  before do
    XPF.configure(:reset) do |config|
      config.normalize_space = false
      config.case_sensitive = true
      config.axial_node = :self
      config.match_ordering = false
    end
    @condition_should_equal = lambda do |config, expected|
      XPF::HTML::Matchers::TD::Hash.new(@values, XPF::Configuration.new(config)).
        condition.should.equal(expected)
    end
  end

  token_comparison = lambda{|exprs, vals, sorted| '(%s) or (%s)' % exprs.map{|e| check_tokens(e, quote_vals(vals), sorted) }}
  unsorted_token_comparison = lambda{|exprs, vals| token_comparison[exprs, vals, false] }
  sorted_token_comparison = lambda{|exprs, vals| token_comparison[exprs, vals, true] }
  string_comparison = lambda{|exprs, val| '(%s) or (%s)' % exprs.map{|e| %|#{e}="#{val}"| }}

  nt, nd = %w{text() .}.map{|e| "normalize-space(#{e})" }
  tt, td = %w{text() .}.map{|e| translate_casing(e) }

  after do
    XPF.configure(:reset)
  end

  describe '> generating condition (for string values)' do

    before do
      @values = {'#' => '1', 'Name' => 'John Tan'}
      @default = './td[%s]/../td[%s]' % @values.map do |field, val|
        comparison = lambda{|v| string_comparison[%w{text() .}, v] }
        th = %|ancestor::table[1]//th[%s][1]| % comparison[field]
        'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val]]
      end
    end

    should 'return expr reflecting specified config[:normalize_space]' do
      {
        false => @default,
        true => './td[%s]/../td[%s]' % @values.map do |field, val|
          comparison = lambda{|v| string_comparison[[nt,nd], v] }
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
          comparison = lambda{|v| string_comparison[[tt,td], v] }
          th = %|ancestor::table[1]//th[%s][1]| % comparison[field.downcase]
          'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val.downcase]]
        end,
      }.each do |val, expected|
        @condition_should_equal[{:case_sensitive => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:axial_node]' do
      {
        :self => @default,
        :descendant => './td[%s]/../td[%s]' % @values.map do |field, val|
          comparison = lambda{|v| string_comparison[%w{text() .}, v] }
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

    before do
      @values = {%w{#} => %w{1}, %w{Full Name} => %w{John Tan}}
      @default = './td[%s]/../td[%s]' % @values.map do |field, val|
        comparison = lambda{|v| unsorted_token_comparison[%w{text() .}, v] }
        th = %|ancestor::table[1]//th[%s][1]| % comparison[field]
        'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val]]
      end
    end

    should 'return expr reflecting specified config[:normalize_space]' do
      {
        false => @default,
        true => './td[%s]/../td[%s]' % @values.map do |field, val|
          comparison = lambda{|v| unsorted_token_comparison[[nt,nd], v] }
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
          comparison = lambda{|v| unsorted_token_comparison[[tt,td], v.map(&:downcase)] }
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
          comparison = lambda{|v| sorted_token_comparison[%w{text() .}, v] }
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
          comparison = lambda{|v| unsorted_token_comparison[%w{text() .}, v] }
          th = %|ancestor::table[1]//th[descendant::*[%s]][1]| % comparison[field]
          'count(%s/preceding-sibling::th)+1][%s][descendant::*[%s]' % [th, th, comparison[val]]
        end
      }.each do |axial_node, expected|
        @condition_should_equal[{:axial_node => axial_node}, expected]
      end
    end

    should "apply negation when config[:comparison] is any of: ! != !> !< !>= !<=" do
      expected = './td[%s]/../td[%s]' % @values.map do |field, val|
        comparison = lambda{|v| unsorted_token_comparison[%w{text() .}, v] }
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
