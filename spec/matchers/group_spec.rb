require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "XPF::Matchers::Group" do

  before do
    XPF.configure(:reset) do |config|
      config.element_matcher = XPF::Spec::Matchers::X::Element
      config.attribute_matcher = XPF::Spec::Matchers::X::Attribute
      config.text_matcher = XPF::Spec::Matchers::X::Text
      config.any_text_matcher = XPF::Spec::Matchers::X::AnyText
      config.literal_matcher = XPF::Spec::Matchers::X::Literal
    end
  end

  after do
    XPF.configure(:reset)
  end

  describe '> generating condition' do

    before do
      @condition_should_equal = lambda do |match_attrs, config, expected|
        XPF::Matchers::Group.new(match_attrs, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should "return nil if match attrs is empty & :axial_node describes 'self' or 'self::*'" do
      [{:axial_node => 'self::*'}, {:axial_node => :self}, %w{self::*}, %w{self}].each do |config|
        [[], {}].each{|match_attrs| @condition_should_equal[match_attrs, config, nil] }
      end
    end

    should "return expr that reflect ONLY axial node if match attrs is empty & :axial_node is 'self::x'" do
      [{:axial_node => 'self::x'}, %w{self::x}].each do |config|
        [[], {}].each{|match_attrs| @condition_should_equal[match_attrs, config, 'self::x'] }
      end
    end

    %w{
      ancestor ancestor-or-self attribute child descendant descendant-or-self
      following following-sibling namespace parent preceding preceding-sibling
    }.each do |axis|
      should "return expr that reflect ONLY axial_node if match attrs is empty & axial_node is '#{axis}::?'" do
        [axis, "#{axis}::*", axis.gsub('-','_').to_sym].each do |axial_node|
          [{:axial_node => axial_node}, %W{#{axial_node}}].each do |config|
            [[], {}].each{|match_attrs| @condition_should_equal[match_attrs, config, "#{axis}::*"] }
          end
        end
      end
    end

    array_match_attrs, expected_array_conds =
      [:e1, :@a1, 'l1', :*, :+, :-, :~], lambda do |config|
        replacement_args = lambda do |extra_config|
          [XPF::Matchers::Matchable::NIL_VALUE.to_s, diff_config(merge_config(config, extra_config)).to_s]
        end
        'self::*%s' %
          [
            '[((x:anytext:%s,%s))]' % replacement_args[{}],
            '[((x:attribute:@a1,%s,%s))]' % replacement_args[{}],
            '[((x:element:e1,%s,%s))]' % replacement_args[{}],
            '[((x:literal:l1,%s))]' % replacement_args[{}][1],
            '[((x:text:%s,%s))]' % replacement_args[{:include_inner_text => false}],
            '[((x:text:%s,%s))]' % replacement_args[{:include_inner_text => true}],
            '[((x:text:%s,%s))]' % replacement_args[{}],
          ].sort.join('')
      end

    hash_match_attrs, expected_hash_conds = {
      :e1 => 'val-e1', :@a1 => 'val-a1', :* => 'val-:*',
      :+ => 'val-:+', :- => 'val-:-', :~ => 'val-:~'
    }, lambda do |config|
      replacement_args = lambda do |val, extra_config|
        [val, diff_config(merge_config(config, extra_config)).to_s]
      end
      'self::*%s' %
        [
          '[((x:anytext:%s,%s))]' % replacement_args['val-:*', {}],
          '[((x:attribute:@a1,%s,%s))]' % replacement_args['val-a1', {}],
          '[((x:element:e1,%s,%s))]' % replacement_args['val-e1', {}],
          '[((x:text:%s,%s))]' % replacement_args['val-:-', {:include_inner_text => false}],
          '[((x:text:%s,%s))]' % replacement_args['val-:+', {:include_inner_text => true}],
          '[((x:text:%s,%s))]' % replacement_args['val-:~', {}],
        ].sort.join('')
    end

    {
      :scope => [{:scope => val1 = '//awe/some/'}, {:scope => val2 = '//wonderous/'}, [val1], [val2]],
      :greedy => [{:greedy => false}, {:greedy => true}, %w{g}, %w{!g}],
      :match_ordering => [{:match_ordering => true}, {:match_ordering => false}, %w{o}, %w{!o}],
      :position => [{:position => 0}, {:position => 10}, %w{0}, %w{10}],
      :case_sensitive => [{:case_sensitive => true}, {:case_sensitive => false}, %w{c}, %w{!c}],
      :include_inner_text => [{:include_inner_text => true}, {:include_inner_text => false}, %w{i}, %w{!i}],
      :normalize_space => [{:normalize_space => true}, {:normalize_space => false}, %w{n}, %w{!n}],
      :comparison => [{:comparison => '!='}, {:comparison => '>='}, %w{!=}, %w{=}]
    }.each do |setting, configs|
      should "return expr ignoring any specified :#{setting}" do
        configs.each do |config|
          {
            array_match_attrs => expected_array_conds[config],
            hash_match_attrs => expected_hash_conds[config]
          }.each do |match_attrs, expected|
            @condition_should_equal[match_attrs, config, expected]
          end
        end
      end
    end
  end

end
