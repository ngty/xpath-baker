require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe "XPF::Matchers::Group" do

  describe '> generating condition' do

    before do
      @condition_should_equal = lambda do |match_attrs, config, expected|
        XPF::Matchers::Group.new(match_attrs, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should "return nil if match attrs is empty & :axial_node is 'self::*'" do
      @condition_should_equal[{}, {:axial_node => 'self::*'}, nil]
    end

    should "return nil if match attrs is empty & :axial_node is :self" do
      @condition_should_equal[{}, {:axial_node => :self}, nil]
    end

    should "return axial_node expr if match attrs is empty & :axial_node is 'self::?' (with '?' not as '*')" do
      @condition_should_equal[{}, {:axial_node => 'self::x'}, './self::x']
    end

    should 'return expr that reflect ONLY axial_node if specified match attrs is empty' do
      @condition_should_equal[{}, {:axial_node => 'attribute::x'}, './attribute::x']
    end

    should "return expr that reflect prepending position if config[:position] is specified as '2^'" do
      expected = './descendant::x[2][normalize-space(@attr1)]'
      @condition_should_equal[[:attr1], {:axial_node => 'descendant::x', :position => '2^'}, expected]
    end

    should "return expr that reflect appending position if config[:position] is specified as '2'" do
      expected = './descendant::x[normalize-space(@attr1)][2]'
      @condition_should_equal[[:attr1], {:axial_node => 'descendant::x', :position => 2}, expected]
    end

    should "return expr that reflect appending position if config[:position] is specified as '2$'" do
      expected = './descendant::x[normalize-space(@attr1)][2]'
      @condition_should_equal[[:attr1], {:axial_node => 'descendant::x', :position => '2$'}, expected]
    end

    should 'return expr that reflect text condition if match attrs is {:text => ..., ...}' do
      expected = './descendant::*[normalize-space(.)="text-x"]'
      @condition_should_equal[{:text => 'text-x'}, {:axial_node => 'descendant::*'}, expected]
    end

    should 'return expr that reflect presence of text if match attrs is [:text, ...]' do
      expected = './descendant::*[normalize-space(.)]'
      @condition_should_equal[[:text], {:axial_node => 'descendant::*'}, expected]
    end

    should 'return expr that reflect attr condition if match attrs is {:attr => ..., ...}' do
      expected = './descendant::*[normalize-space(@attr)="value-x"]'
      @condition_should_equal[{:attr => 'value-x'}, {:axial_node => 'descendant::*'}, expected]
    end

    should 'return expr that reflect presence of attr if match attrs is [:attr, ...]' do
      expected = './descendant::*[normalize-space(@attr)]'
      @condition_should_equal[[:attr], {:axial_node => 'descendant::*'}, expected]
    end

    should "return expr that reflect expr as literal if match attrs is ['position()=99', ...]" do
      expected = './descendant::*[position()=99]'
      @condition_should_equal[['position()=99'], {:axial_node => 'descendant::*'}, expected]
    end

  end

end
