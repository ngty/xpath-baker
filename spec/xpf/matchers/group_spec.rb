require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe "XPF::Matchers::Group" do

  describe '> generating condition' do

    before do
      @condition_should_equal = lambda do |match_attrs, config, expected|
        XPF::Matchers::Group.new(match_attrs, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'return expr that reflect ONLY axis if specified match attrs is empty' do
      @condition_should_equal[{}, {:axis => 'attribute::x'}, './attribute::x']
    end

    should 'return expr that reflect text condition if match attrs is {:text => ..., ...}' do
      expected = './descendant::*[normalize-space(.)="text-x"]'
      @condition_should_equal[{:text => 'text-x'}, {:axis => 'descendant::*'}, expected]
    end

    should 'return expr that reflect attr condition if match attrs is {:attr => ..., ...}' do
      expected = './descendant::*[normalize-space(@attr)="value-x"]'
      @condition_should_equal[{:attr => 'value-x'}, {:axis => 'descendant::*'}, expected]
    end

  end

end
