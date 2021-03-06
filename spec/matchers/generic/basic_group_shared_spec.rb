shared "basic group matcher" do

  before do
    XPathBaker.configure(:reset) do |config|
      config.element_matcher = XPathBaker::Spec::Matchers::X::Element
      config.attribute_matcher = XPathBaker::Spec::Matchers::X::Attribute
      config.text_matcher = XPathBaker::Spec::Matchers::X::Text
      config.any_text_matcher = XPathBaker::Spec::Matchers::X::AnyText
      config.literal_matcher = XPathBaker::Spec::Matchers::X::Literal
    end
  end

  after do
    XPathBaker.configure(:reset)
  end

  describe '> generating condition' do

    before do
      @condition = lambda do |match_attrs, config|
        @matcher_klass.new(match_attrs, XPathBaker::Configuration.new(config)).condition
      end
      @condition_should_equal = lambda do |match_attrs, config, expected|
        @condition[match_attrs, config].should.equal(expected)
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

    array_match_attrs = [:e1, :@a1, 'l1', :*, :+, :-, :~]
    hash_match_attrs = {:e1 => 've1', :@a1 => 'va1', :* => 'v:*', :+ => 'v:+', :- => 'v:-', :~ => 'v:~'}

    {
      :text_matcher => [XPathBaker::Spec::Matchers::Y::Text, %w{y:text:XPathBaker_NIL_VALUE}, %w{y:text:v:+ y:text:v:- y:text:v:~}],
      :any_text_matcher => [XPathBaker::Spec::Matchers::Y::AnyText, %w{y:anytext:XPathBaker_NIL_VALUE}, %w{y:anytext:v:*}],
      :element_matcher => [XPathBaker::Spec::Matchers::Y::Element, %w{y:element:e1,XPathBaker_NIL_VALUE}, %w{y:element:e1,ve1}],
      :attribute_matcher => [XPathBaker::Spec::Matchers::Y::Attribute, %w{y:attribute:@a1,XPathBaker_NIL_VALUE}, %w{y:attribute:@a1,va1}],
      :literal_matcher => [XPathBaker::Spec::Matchers::Y::Literal, %w{y:literal:l1}, %w{}]
    }.each do |setting, (klass, expected_array_conds, expected_hash_conds)|
      should "return expr that reflect specified :#{setting}" do
        [{setting => klass}, [klass.to_s], [klass]].each do |config|
          {array_match_attrs => expected_array_conds, hash_match_attrs => expected_hash_conds}.
            each do |match_attrs, expected_conds|
              expected_conds.each do |expected_cond|
                @condition[match_attrs, {}].should.not.match(/#{expected_cond}/)
                @condition[match_attrs, config].should.match(/#{expected_cond}/)
              end
            end
        end
      end
    end

    replacement_args = lambda do |val, config1, config2|
      [
        val || XPathBaker::Matchers::Matchable::NIL_VALUE.to_s,
        diff_config(merge_config(config1, config2)).to_s
      ]
    end

    expected_array_conds = lambda do |config|
      'self::*%s' %
        [
          '[((x:anytext:%s,%s))]' % replacement_args[nil, config, {}],
          '[((x:attribute:@a1,%s,%s))]' % replacement_args[nil, config, {}],
          '[((x:element:e1,%s,%s))]' % replacement_args[nil, config, {}],
          '[((x:literal:l1,%s))]' % replacement_args[nil, config, {}][1],
          '[((x:text:%s,%s))]' % replacement_args[nil, config, {:include_inner_text => false}],
          '[((x:text:%s,%s))]' % replacement_args[nil, config, {:include_inner_text => true}],
          '[((x:text:%s,%s))]' % replacement_args[nil, config, {}],
        ].sort.join('')
    end

    expected_hash_conds = lambda do |config|
      'self::*%s' %
        [
          '[((x:anytext:%s,%s))]' % replacement_args['v:*', config, {}],
          '[((x:attribute:@a1,%s,%s))]' % replacement_args['va1', config, {}],
          '[((x:element:e1,%s,%s))]' % replacement_args['ve1', config, {}],
          '[((x:text:%s,%s))]' % replacement_args['v:-', config, {:include_inner_text => false}],
          '[((x:text:%s,%s))]' % replacement_args['v:+', config, {:include_inner_text => true}],
          '[((x:text:%s,%s))]' % replacement_args['v:~', config, {}],
        ].sort.join('')
    end

    valid_config_settings_args(
      :scope, :greedy, :match_ordering, :position, :case_sensitive, :include_inner_text,
      :normalize_space, :comparison
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
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
