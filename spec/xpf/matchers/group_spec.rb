require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe "XPF::Matchers::Group" do

  describe '> initializing axis_node' do

    before do
      @axis_node_should_equal = lambda do |axis_node, config, expected|
        XPF::Matchers::Group.new(axis_node, {}, XPF::Configuration.new(config)).
          axis_node.should.equal(expected)
      end
    end

    should 'set as default if none is specified' do
      @axis_node_should_equal[nil, {:axis => :descendant_or_self}, 'descendant-or-self::*']
    end

    should "set node portion as '*' if specified is partially described" do
      @axis_node_should_equal[:descendant_or_self, {:axis => :descendant}, 'descendant-or-self::*']
    end

    should "set to specified if specified is fully described" do
      @axis_node_should_equal['descendant::x', {}, 'descendant::x']
    end

    should "raise XPF::InvalidAxisNodeError if axis portion is invalid" do
      lambda { @axis_node_should_equal['awesome::x', {}, 'awesome::x'] }.
        should.raise(XPF::InvalidAxisNodeError).
        message.should.equal("Axis node 'awesome::x' descibes an invalid axis !!")
    end

  end

  describe '> generating condition' do

    before do
      @condition_should_equal = lambda do |axis_node, match_attrs, expected|
        XPF::Matchers::Group.new(axis_node, match_attrs, XPF::Configuration.new({})).
          condition.should.equal(expected)
      end
    end

    should 'return nil if specified match attrs is empty' do
      @condition_should_equal[nil, {}, nil]
    end

    should 'return expr that reflect text condition if match attrs is {:text => ..., ...}' do
      @condition_should_equal[nil, {:text => 'text-x'}, './self::*[normalize-space(.)="text-x"]']
    end

    should 'return expr that reflect attr condition if match attrs is {:attr => ..., ...}' do
      @condition_should_equal[nil, {:attr => 'value-x'}, './self::*[normalize-space(@attr)="value-x"]']
    end

  end

end
