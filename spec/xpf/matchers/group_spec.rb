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
      [{:axial_node => 'self::*'}, %w{self::*}].each do |config|
        @condition_should_equal[{}, config, nil]
      end
    end

    should "return nil if match attrs is empty & :axial_node is :self" do
      [{:axial_node => :self}, %w{self}].each do |config|
        @condition_should_equal[{}, config, nil]
      end
    end

    should "return axial_node expr if match attrs is empty & :axial_node is 'self::?' (with '?' not as '*')" do
      [{:axial_node => 'self::x'}, %w{self::x}].each do |config|
        @condition_should_equal[{}, config, './self::x']
      end
    end

    should 'return expr that reflect ONLY axial_node if specified match attrs is empty' do
      [{:axial_node => 'attribute::x'}, %w{attribute::x}].each do |config|
        @condition_should_equal[{}, config, './attribute::x']
      end
    end

    should "return expr that reflect prepending position if config[:position] is specified as '2^'" do
      [{:axial_node => 'descendant::x', :position => '2^'}, %w{descendant::x 2^}].each do |config|
        @condition_should_equal[[:@attr1], config, './descendant::x[2][normalize-space(@attr1)]']
      end
    end

    should "return expr that reflect appending position if config[:position] is specified as '2'" do
      [{:axial_node => 'descendant::x', :position => 2}, %w{descendant::x 2}].each do |config|
        @condition_should_equal[[:@attr1], config, './descendant::x[normalize-space(@attr1)][2]']
      end
    end

    should "return expr that reflect appending position if config[:position] is specified as '2$'" do
      [{:axial_node => 'descendant::x', :position => '2$'}, %w{descendant::x 2$}].each do |config|
        @condition_should_equal[[:@attr1], config, './descendant::x[normalize-space(@attr1)][2]']
      end
    end

    should 'return expr that reflect either direct or all inner text condition if match attrs is {:* => ..., ...}' do
      [
        {:axial_node => 'descendant::*', :include_inner_text => true},
        {:axial_node => 'descendant::*', :include_inner_text => false},
        %w{descendant::* i},
        %w{descendant::* !i},
      ].each do |config|
        tokens = %w{text() .}.map{|s| %|normalize-space(#{s})="text-x"| }
        @condition_should_equal[{:* => 'text-x'}, config, './descendant::*[(%s) or (%s)]' % tokens]
      end
    end

    should 'return expr that reflect presence of either direct or all inner text if match attrs is [:*, ...]' do
      [
        {:axial_node => 'descendant::*', :include_inner_text => true},
        {:axial_node => 'descendant::*', :include_inner_text => false},
        %w{descendant::* i},
        %w{descendant::* !i}
      ].each do |config|
        tokens = %w{text() .}.map{|s| %|normalize-space(#{s})| }
        @condition_should_equal[[:*], config, './descendant::*[(%s) or (%s)]' % tokens]
      end
    end

    should 'return expr that reflect all inner text condition if match attrs is {:+ => ..., ...}' do
      [
        {:axial_node => 'descendant::*', :include_inner_text => true},
        {:axial_node => 'descendant::*', :include_inner_text => false},
        %w{descendant::* i},
        %w{descendant::* !i},
      ].each do |config|
        @condition_should_equal[{:+ => 'text-x'}, config, './descendant::*[normalize-space(.)="text-x"]']
      end
    end

    should 'return expr that reflect presence of all inner text if match attrs is [:+, ...]' do
      [
        {:axial_node => 'descendant::*', :include_inner_text => true},
        {:axial_node => 'descendant::*', :include_inner_text => false},
        %w{descendant::* i},
        %w{descendant::* !i}
      ].each do |config|
        @condition_should_equal[[:+], config, './descendant::*[normalize-space(.)]']
      end
    end

    should 'return expr that reflect direct text condition if match attrs is {:- => ..., ...}' do
      [
        {:axial_node => 'descendant::*', :include_inner_text => true},
        {:axial_node => 'descendant::*', :include_inner_text => false},
        %w{descendant::* i},
        %w{descendant::* !i},
      ].each do |config|
        @condition_should_equal[{:- => 'text-x'}, config, './descendant::*[normalize-space(text())="text-x"]']
      end
    end

    should 'return expr that reflect presence of direct text if match attrs is [:-, ...]' do
      [
        {:axial_node => 'descendant::*', :include_inner_text => true},
        {:axial_node => 'descendant::*', :include_inner_text => false},
        %w{descendant::* i},
        %w{descendant::* !i},
      ].each do |config|
        @condition_should_equal[[:-], config, './descendant::*[normalize-space(text())]']
      end
    end

    should 'return expr that reflect variable text condition if match attrs is {:~ => ..., ...}' do
      [{:axial_node => 'descendant::*', :include_inner_text => true}, %w{descendant::* i}].each do |config|
        @condition_should_equal[{:~ => 'text-x'}, config, './descendant::*[normalize-space(.)="text-x"]']
      end
      [{:axial_node => 'descendant::*', :include_inner_text => false}, %w{descendant::* !i}].each do |config|
        @condition_should_equal[{:~ => 'text-x'}, config, './descendant::*[normalize-space(text())="text-x"]']
      end
    end

    should 'return expr that reflect presence of variable text if match attrs is [:~, ...]' do
      [{:axial_node => 'descendant::*', :include_inner_text => true}, %w{descendant::* i}].each do |config|
        @condition_should_equal[[:~], config, './descendant::*[normalize-space(.)]']
      end
      [{:axial_node => 'descendant::*', :include_inner_text => false}, %w{descendant::* !i}].each do |config|
        @condition_should_equal[[:~], config, './descendant::*[normalize-space(text())]']
      end
    end

    should 'return expr that reflect attr condition if match attrs is {:attr1 => ..., ...}' do
      [{:axial_node => 'descendant::*'}, %w{descendant::*}].each do |config|
        @condition_should_equal[{:@attr1 => 'value-x'}, config, './descendant::*[normalize-space(@attr1)="value-x"]']
      end
    end

    should 'return expr that reflect presence of attr if match attrs is [:attr1, ...]' do
      [{:axial_node => 'descendant::*'}, %w{descendant::*}].each do |config|
        @condition_should_equal[[:@attr1], config, './descendant::*[normalize-space(@attr1)]']
      end
    end

    should "return expr that reflect expr as literal if match attrs is ['position()=99', ...]" do
      [{:axial_node => 'descendant::*'}, %w{descendant::*}].each do |config|
        @condition_should_equal[['position()=99'], config, './descendant::*[position()=99]']
      end
    end

  end

end
