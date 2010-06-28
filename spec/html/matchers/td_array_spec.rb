require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'xpf/html'

describe "XPF::HTML::Matchers::TD::Array" do

  before do
    XPF.configure(:reset) do |config|
      config.normalize_space = false
      config.case_sensitive = true
      config.axial_node = :self
      config.match_ordering = false
    end
  end

  after do
    XPF.configure(:reset)
  end

  describe '> generating condition (for string values)' do

    before do
      @values = %w{AWE SOME}
      @default = './td[%s]/../td[%s]' % @values.map{|val| %|(text()="#{val}") or (.="#{val}")| }
      @condition_should_equal = lambda do |config, expected|
        XPF::HTML::Matchers::TD::Array.new(@values, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'return expr reflecting specified config[:normalize_space]' do
      {
        true => './td[%s]/../td[%s]' %
          @values.map{|val| %|(normalize-space(text())="#{val}") or (normalize-space(.)="#{val}")| },
        false => @default
      }.each do |val, expected|
        @condition_should_equal[{:normalize_space => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:case_sensitive]' do
      {
        false => './td[%s]/../td[%s]' % @values.
          map{|val| '(%s) or (%s)' % %w{text() .}.map{|e| %|#{translate_casing(e)}="#{val.downcase}"| } },
        true => @default
      }.each do |val, expected|
        @condition_should_equal[{:case_sensitive => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:match_ordering]' do
      {
        true => './td[%s]/following-sibling::td[%s]' %
          @values.map{|val| %|(text()="#{val}") or (.="#{val}")| },
        false => @default
      }.each do |val, expected|
        @condition_should_equal[{:match_ordering => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:axial_node]' do
      {
        :self => @default,
        :descendant => './td[descendant::*[%s]]/../td[descendant::*[%s]]' %
          @values.map{|val| %|(text()="#{val}") or (.="#{val}")| }
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

    before do
      @values = [%w{AWE SOME}, %w{WONDER}]
      @default = './td[%s]/../td[%s]' % @values.
        map{|vals| '(%s) or (%s)' % %w{text() .}.map{|e| check_tokens(e, vals.map{|v| %|"#{v}"| }, false) } }
      @condition_should_equal = lambda do |config, expected|
        XPF::HTML::Matchers::TD::Array.new(@values, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'return expr reflecting specified config[:normalize_space]' do
      {
        true => './td[%s]/../td[%s]' % @values.map{|vals| '(%s) or (%s)' % %w{text() .}.
          map{|e| check_tokens("normalize-space(#{e})", vals.map{|v| %|"#{v}"| }, false) }},
        false => @default
      }.each do |val, expected|
        @condition_should_equal[{:normalize_space => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:case_sensitive]' do
      {
        false => './td[%s]/../td[%s]' % @values.map{|vals| '(%s) or (%s)' % %w{text() .}.
          map{|e| check_tokens(translate_casing(e), vals.map{|v| %|"#{v.downcase}"| }, false) }},
        true => @default
      }.each do |val, expected|
        @condition_should_equal[{:case_sensitive => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:match_ordering]' do
      {
        true => './td[%s]/following-sibling::td[%s]' % @values.map{|vals| '(%s) or (%s)' % %w{text() .}.
          map{|e| check_tokens(e, vals.map{|v| %|"#{v}"| }, true) }},
        false => @default
      }.each do |val, expected|
        @condition_should_equal[{:match_ordering => val}, expected]
      end
    end

    should 'return expr reflecting specified config[:axial_node]' do
      {
        :descendant => './td[descendant::*[%s]]/../td[descendant::*[%s]]' % @values.
          map{|vals| '(%s) or (%s)' % %w{text() .}.map{|e| check_tokens(e, vals.map{|v| %|"#{v}"| }, false) }},
        :self => @default,
      }.each do |axial_node, expected|
        @condition_should_equal[{:axial_node => axial_node}, expected]
      end
    end

    should "apply negation when config[:comparison] is any of: ! != !> !< !>= !<=" do
      expected = './td[not(%s)]/../td[not(%s)]' % @values.
        map{|vals| '(%s) or (%s)' % %w{text() .}.map{|e| check_tokens(e, vals.map{|v| %|"#{v}"| }, false) }}
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
