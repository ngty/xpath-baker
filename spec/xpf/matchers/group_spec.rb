require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe "XPF::Matchers::Group" do

  describe '> generating condition' do

    before do
      @condition_should_equal = lambda do |match_attrs, config, expected|
        XPF::Matchers::Group.new(match_attrs, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should "return nil if match attrs is empty & :axis is 'self::*'" do
      @condition_should_equal[{}, {:axis => 'self::*'}, nil]
    end

    should "return axis expr if match attrs is empty & :axis is 'self::?' (with '?' not as '*')" do
      @condition_should_equal[{}, {:axis => 'self::x'}, './self::x']
    end

    should 'return expr that reflect ONLY axis if specified match attrs is empty' do
      @condition_should_equal[{}, {:axis => 'attribute::x'}, './attribute::x']
    end

    should "return expr that reflect prepending position if config[:position] is specified as '^2'" do
      expected = './descendant::x[2][normalize-space(@attr1)]'
      @condition_should_equal[[:attr1], {:axis => 'descendant::x', :position => '^2'}, expected]
    end

    should "return expr that reflect appending position if config[:position] is specified as '2'" do
      expected = './descendant::x[normalize-space(@attr1)][2]'
      @condition_should_equal[[:attr1], {:axis => 'descendant::x', :position => 2}, expected]
    end

    should "return expr that reflect appending position if config[:position] is specified as '2$'" do
      expected = './descendant::x[normalize-space(@attr1)][2]'
      @condition_should_equal[[:attr1], {:axis => 'descendant::x', :position => '2$'}, expected]
    end

    should 'return expr that reflect text condition if match attrs is {:text => ..., ...}' do
      expected = './descendant::*[normalize-space(.)="text-x"]'
      @condition_should_equal[{:text => 'text-x'}, {:axis => 'descendant::*'}, expected]
    end

    should 'return expr that reflect presence of text if match attrs is [:text, ...]' do
      expected = './descendant::*[normalize-space(.)]'
      @condition_should_equal[[:text], {:axis => 'descendant::*'}, expected]
    end

    should 'return expr that reflect attr condition if match attrs is {:attr => ..., ...}' do
      expected = './descendant::*[normalize-space(@attr)="value-x"]'
      @condition_should_equal[{:attr => 'value-x'}, {:axis => 'descendant::*'}, expected]
    end

    should 'return expr that reflect presence of attr if match attrs is [:attr, ...]' do
      expected = './descendant::*[normalize-space(@attr)]'
      @condition_should_equal[[:attr], {:axis => 'descendant::*'}, expected]
    end

    should "return expr that reflect expr as literal if match attrs is ['position()=99', ...]" do
      expected = './descendant::*[position()=99]'
      @condition_should_equal[['position()=99'], {:axis => 'descendant::*'}, expected]
    end

  end

end
