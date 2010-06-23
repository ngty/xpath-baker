require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'XPF::Matchers::AnyText' do

  before { @text_matcher = XPF::Matchers::AnyText }

  describe '> generating condition (with valid string value)' do

    before do
      @val = 'text-x'
      @default = %|(normalize-space(text())="#{@val}") or (normalize-space(.)="#{@val}")|
      @condition_should_equal = lambda do |config, expected|
        @text_matcher.new(@val, XPF::Configuration.new(config)).condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      @condition_should_equal[{:normalize_space => false}, %|(text()="#{@val}") or (.="#{@val}")|]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      tokens = %w{text() .}.map{|s| translate_casing("normalize-space(#{s})") + %|="#{@val.downcase}"| }
      @condition_should_equal[{:case_sensitive => false}, '(%s) or (%s)' % tokens]
    end

    should 'include inner text when config[:include_inner_text] is true' do
      @condition_should_equal[{:include_inner_text => true}, @default]
    end

    should 'elegantly handle quoting of value with double quote (")' do
      @val, quoted = 'text-"x"', %|concat("text-",'"',"x",'"',"")|
      tokens = %w{text() .}.map{|s| "normalize-space(#{s})=#{quoted}" }
      @condition_should_equal[{}, '(%s) or (%s)' % tokens]
    end

    should 'ignore config[:include_inner_text]' do
      @condition_should_equal[{:include_inner_text => true}, @default]
      @condition_should_equal[{:include_inner_text => false}, @default]
    end

  end

  describe '> generating condition (w valid single element array value)' do

    before do
      @val = 'text-x'
      tokens = %w{text() .}.map{|s| check_tokens("normalize-space(#{s})", [%|"#{@val}"|]) }
      @default = '(%s) or (%s)' % tokens
      @condition_should_equal = lambda do |config, expected|
        @text_matcher.new([@val], XPF::Configuration.new(config)).condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      tokens = %w{text() .}.map{|s| check_tokens(translate_casing("normalize-space(#{s})"), [%|"#{@val}"|]) }
      @condition_should_equal[{:case_sensitive => false}, '(%s) or (%s)' % tokens]
    end

    should 'ignore config[:include_inner_text]' do
      @condition_should_equal[{:include_inner_text => true}, @default]
      @condition_should_equal[{:include_inner_text => false}, @default]
    end

  end

  describe '> generating condition (w valid multi elements array value)' do

    before do
      @vals = %w{val-x1 val-x2 val-x3}
      tokens = %w{text() .}.map{|s| check_tokens("normalize-space(#{s})", @vals.map{|v| %|"#{v}"| }) }
      @default = '(%s) or (%s)' % tokens
      @condition_should_equal = lambda do |config, expected|
        @text_matcher.new(@vals, XPF::Configuration.new(config)).condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      tokens = %w{text() .}.map{|s| check_tokens(s, @vals.map{|v| %|"#{v}"| }) }
      @condition_should_equal[{:normalize_space => false}, '(%s) or (%s)' % tokens]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      tokens = %w{text() .}.map do |s|
        check_tokens(translate_casing("normalize-space(#{s})"), @vals.map{|v| %|"#{v}"| })
      end
      @condition_should_equal[{:case_sensitive => false}, '(%s) or (%s)' % tokens]
    end

    should 'honor ordering when config[:match_ordering] is true' do
      @condition_should_equal[{:match_ordering => true}, @default]
    end

    should 'not not honor ordering when config[:match_ordering] is false' do
      tokens = %w{text() .}.map{|s| check_tokens("normalize-space(#{s})", @vals.map{|v| %|"#{v}"| }, false) }
      @condition_should_equal[{:match_ordering => false}, '(%s) or (%s)' % tokens]
    end

    should 'ignore config[:include_inner_text]' do
      @condition_should_equal[{:include_inner_text => true}, @default]
      @condition_should_equal[{:include_inner_text => false}, @default]
    end

  end

  describe '> generating condition (with invalid value NIL_VALUE)' do

    before do
      @val = XPF::Matchers::Matchable::NIL_VALUE
      @default = '(%s) or (%s)' % %w{text() .}.map{|s| %|normalize-space(#{s})| }
      @condition_should_equal = lambda do |config, expected|
        @text_matcher.new(@val, XPF::Configuration.new(config)).condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      @condition_should_equal[{:normalize_space => false}, '(%s) or (%s)' % %w{text() . }]
    end

    should 'ignore config[:include_inner_text]' do
      @condition_should_equal[{:include_inner_text => true}, @default]
      @condition_should_equal[{:include_inner_text => false}, @default]
    end

  end

end