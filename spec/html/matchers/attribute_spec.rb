require File.join(spec_root = File.join(File.dirname(__FILE__), '..', '..'), 'spec_helper')
require File.join(spec_root, 'xpf', 'matchers', 'basic_attribute_shared_spec')
require 'xpf/html'

describe "XPF::HTML::Matchers::Attribute (w.r.t @class)" do

  before do
    @attr_matcher = XPF::HTML::Matchers::Attribute
    @name, @val = :class, 'blue red'
  end

  behaves_like 'basic attribute matcher'

  describe '> generating condition (w @class as a single element array)' do

    before do
      @name, @val = :class, %w{aweso-me}
      @default = check_tokens("normalize-space(@#{@name})", %|"#{@val}"|)[0]
      @condition_should_equal = lambda do |config, expected|
        @attr_matcher.new(@name, @val, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      expected = check_tokens("@#{@name}", %|"#{@val}"|)[0]
      @condition_should_equal[{:normalize_space => false}, expected]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      attr_expr = translate_casing("normalize-space(@#{@name})")
      expected = check_tokens(translate_casing("normalize-space(@#{@name})"), %|"#{@val}"|)[0]
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

  end

  describe '> generating condition (w @class as a multi elements array)' do

    before do
      @name, @vals = :class, %w{aweso-me wonder-fu}
      @default = check_tokens("normalize-space(@#{@name})", @vals.map{|v| %|"#{v}"| }).join(' and ')
      @condition_should_equal = lambda do |config, expected|
        @attr_matcher.new(@name, @vals, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      expected = check_tokens("@#{@name}", @vals.map{|v| %|"#{v}"| }).join(' and ')
      @condition_should_equal[{:normalize_space => false}, expected]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      expected = check_tokens(translate_casing("normalize-space(@#{@name})"), @vals.map{|v| %|"#{v}"| }).join(' and ')
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

  end

end

describe "XPF::HTML::Matchers::Attribute (w.r.t non @class)" do
  before { @attr_matcher = XPF::HTML::Matchers::Attribute }
  behaves_like 'basic attribute matcher'
end
