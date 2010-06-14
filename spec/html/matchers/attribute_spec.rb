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
      @default = '(%s)' % [
        %|normalize-space(@#{@name})="#{@val}"|,
        %|contains(normalize-space(@#{@name})," #{@val} ")|,
        %|starts-with(normalize-space(@#{@name}),"#{@val} ")|,
        %|starts-with(normalize-space(@#{@name}),"#{@val.to_s.reverse} ")|,
      ].join(' or ')
      @condition_should_equal = lambda do |config, expected|
        @attr_matcher.new(@name, @val, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      attr_expr = "@#{@name}"
      expected = '(%s)' % [
        %|%s="%s"|,
        %|contains(%s," %s ")|,
        %|starts-with(%s,"%s ")|,
        %|starts-with(%s,"%s ")|,
      ].join(' or ') % ([attr_expr, @val.to_s]*3 + [attr_expr, @val.to_s.reverse])
      @condition_should_equal[{:normalize_space => false}, expected]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      attr_expr = translate_casing("normalize-space(@#{@name})")
      expected = '(%s)' % [
        %|%s="%s"|,
        %|contains(%s," %s ")|,
        %|starts-with(%s,"%s ")|,
        %|starts-with(%s,"%s ")|,
      ].join(' or ') % ([attr_expr, @val.to_s.downcase]*3 + [attr_expr, @val.to_s.reverse.downcase])
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

  end

  describe '> generating condition (w @class as a multi elements array)' do

    before do
      @name, @vals = :class, %w{aweso-me wonder-fu}
      @default = @vals.map do |val|
        '(%s)' % [
          %|normalize-space(@#{@name})="#{val}"|,
          %|contains(normalize-space(@#{@name})," #{val} ")|,
          %|starts-with(normalize-space(@#{@name}),"#{val} ")|,
          %|starts-with(normalize-space(@#{@name}),"#{val.reverse} ")|,
        ].join(' or ')
      end.join(' and ')
      @condition_should_equal = lambda do |config, expected|
        @attr_matcher.new(@name, @vals, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      expected = @vals.map do |val|
        '(%s)' % [
          %|@#{@name}="#{val}"|,
          %|contains(@#{@name}," #{val} ")|,
          %|starts-with(@#{@name},"#{val} ")|,
          %|starts-with(@#{@name},"#{val.reverse} ")|,
        ].join(' or ')
      end.join(' and ')
      @condition_should_equal[{:normalize_space => false}, expected]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      attr_expr = translate_casing("normalize-space(@#{@name})")
      expected = @vals.map do |val|
        '(%s)' % [
          %|%s="%s"|,
          %|contains(%s," %s ")|,
          %|starts-with(%s,"%s ")|,
          %|starts-with(%s,"%s ")|,
        ].join(' or ') % ([attr_expr, val.downcase]*3 + [attr_expr, val.reverse.downcase])
      end.join(' and ')
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

  end

end

describe "XPF::HTML::Matchers::Attribute (w.r.t non @class)" do
  before { @attr_matcher = XPF::HTML::Matchers::Attribute }
  behaves_like 'basic attribute matcher'
end
