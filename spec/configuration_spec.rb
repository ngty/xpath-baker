require File.join(File.dirname(__FILE__), 'spec_helper')

describe "XPathBaker::Configuration" do

  before do
    XPathBaker.configure(:reset)
  end

  valid_axial_node_args = {
    :ancestor               => 'ancestor::*',           'ancestor'              => 'ancestor::*',
    :ancestor_or_self       => 'ancestor-or-self::*',   'ancestor-or-self'      => 'ancestor-or-self::*',
    :child                  => 'child::*',              'child'                 => 'child::*',
    :descendant             => 'descendant::*',         'descendant'            => 'descendant::*',
    :descendant_or_self     => 'descendant-or-self::*', 'descendant-or-self'    => 'descendant-or-self::*',
    :following              => 'following::*',          'following'             => 'following::*',
    :following_sibling      => 'following-sibling::*',  'following-sibling'     => 'following-sibling::*',
    :parent                 => 'parent::*',             'parent'                => 'parent::*',
    :preceding              => 'preceding::*',          'preceding'             => 'preceding::*',
    :preceding_sibling      => 'preceding-sibling::*',  'preceding-sibling'     => 'preceding-sibling::*',
    :self                   => 'self::*',               'self'                  => 'self::*',
    'ancestor::'            => 'ancestor::*',           'ancestor::x'           => 'ancestor::x',
    'ancestor-or-self::'    => 'ancestor-or-self::*',   'ancestor-or-self::x'   => 'ancestor-or-self::x',
    'child::'               => 'child::*',              'child::x'              => 'child::x',
    'descendant::'          => 'descendant::*',         'descendant::x'         => 'descendant::x',
    'descendant-or-self::'  => 'descendant-or-self::*', 'descendant-or-self::x' => 'descendant-or-self::x',
    'following::'           => 'following::*',          'following::x'          => 'following::x',
    'following-sibling::'   => 'following-sibling::*',  'following-sibling::x'  => 'following-sibling::x',
    'parent::'              => 'parent::*',             'parent::x'             => 'parent::x',
    'preceding::'           => 'preceding::*',          'preceding::x'          => 'preceding::x',
    'preceding-sibling::'   => 'preceding-sibling::*',  'preceding-sibling::x'  => 'preceding-sibling::x',
    'self::'                => 'self::*',               'self::x'               => 'self::x',
    'ancestor::*'           => 'ancestor::*',
    'ancestor-or-self::*'   => 'ancestor-or-self::*',
    'child::*'              => 'child::*',
    'descendant::*'         => 'descendant::*',
    'descendant-or-self::*' => 'descendant-or-self::*',
    'following::*'          => 'following::*',
    'following-sibling::*'  => 'following-sibling::*',
    'parent::*'             => 'parent::*',
    'preceding::*'          => 'preceding::*',
    'preceding-sibling::*'  => 'preceding-sibling::*',
    'self::*'               => 'self::*',
  }

  valid_comparison_args = {
    '='   => ['=', {:negate? => false}],   :eq   => ['=', {:negate? => false}],
    '!'   => ['=', {:negate? => true}],    :not  => ['=', {:negate? => true}],
    '!='  => ['=', {:negate? => true}],    :neq  => ['=', {:negate? => true}],
    '>'   => ['>', {:negate? => false}],   :gt   => ['>', {:negate? => false}],
    '!>'  => ['>', {:negate? => true}],    :ngt  => ['>', {:negate? => true}],
    '<'   => ['<', {:negate? => false}],   :lt   => ['<', {:negate? => false}],
    '!<'  => ['<', {:negate? => true}],    :nlt  => ['<', {:negate? => true}],
    '>='  => ['>=', {:negate? => false}],  :gte  => ['>=', {:negate? => false}],
    '!>=' => ['>=', {:negate? => true}],   :ngte => ['>=', {:negate? => true}],
    '<='  => ['<=', {:negate? => false}],  :lte  => ['<=', {:negate? => false}],
    '!<=' => ['<=', {:negate? => true}],   :nlte => ['<=', {:negate? => true}],
    :equal                     => ['=', {:negate? => false}],
    :not_equal                 => ['=', {:negate? => true}],
    :greater_than              => ['>', {:negate? => false}],
    :not_greater_than          => ['>', {:negate? => true}],
    :less_than                 => ['<', {:negate? => false}],
    :not_less_than             => ['<', {:negate? => true}],
    :greater_than_or_equal     => ['>=', {:negate? => false}],
    :not_greater_than_or_equal => ['>=', {:negate? => true}],
    :less_than_or_equal        => ['<=', {:negate? => false}],
    :not_less_than_or_equal    => ['<=', {:negate? => true}],
  }

  valid_position_args = {
    0       => [nil, {}],
    2       => ['[2]', {:start? => false, :end? => true}],
    '2^'    => ['[2]', {:start? => true, :end? => false}],
    '2$'    => ['[2]', {:start? => false, :end? => true}],
    '!2'    => ['[position()!=2]', {:start? => false, :end? => true}],
    '!2^'   => ['[position()!=2]', {:start? => true, :end? => false}],
    '!2$'   => ['[position()!=2]', {:start? => false, :end? => true}],
    '1~2'   => ['[position()>=1 and position()<=2]', {:start? => false, :end? => true}],
    '1~2^'  => ['[position()>=1 and position()<=2]', {:start? => true, :end? => false}],
    '1~2$'  => ['[position()>=1 and position()<=2]', {:start? => false, :end? => true}],
    '!1~2'  => ['[not(position()>=1 and position()<=2)]', {:start? => false, :end? => true}],
    '!1~2^' => ['[not(position()>=1 and position()<=2)]', {:start? => true, :end? => false}],
    '!1~2$' => ['[not(position()>=1 and position()<=2)]', {:start? => false, :end? => true}],
    '>=2'   => ['[position()>=2]', {:start? => false, :end? => true}],
    '>=2^'  => ['[position()>=2]', {:start? => true, :end? => false}],
    '>=2$'  => ['[position()>=2]', {:start? => false, :end? => true}],
    '!>=2'  => ['[not(position()>=2)]', {:start? => false, :end? => true}],
    '!>=2^' => ['[not(position()>=2)]', {:start? => true, :end? => false}],
    '!>=2$' => ['[not(position()>=2)]', {:start? => false, :end? => true}],
    '>2'    => ['[position()>2]', {:start? => false, :end? => true}],
    '>2^'   => ['[position()>2]', {:start? => true, :end? => false}],
    '>2$'   => ['[position()>2]', {:start? => false, :end? => true}],
    '!>2'   => ['[not(position()>2)]', {:start? => false, :end? => true}],
    '!>2^'  => ['[not(position()>2)]', {:start? => true, :end? => false}],
    '!>2$'  => ['[not(position()>2)]', {:start? => false, :end? => true}],
    '<=2'   => ['[position()<=2]', {:start? => false, :end? => true}],
    '<=2^'  => ['[position()<=2]', {:start? => true, :end? => false}],
    '<=2$'  => ['[position()<=2]', {:start? => false, :end? => true}],
    '!<=2'  => ['[not(position()<=2)]', {:start? => false, :end? => true}],
    '!<=2^' => ['[not(position()<=2)]', {:start? => true, :end? => false}],
    '!<=2$' => ['[not(position()<=2)]', {:start? => false, :end? => true}],
    '<2'    => ['[position()<2]', {:start? => false, :end? => true}],
    '<2^'   => ['[position()<2]', {:start? => true, :end? => false}],
    '<2$'   => ['[position()<2]', {:start? => false, :end? => true}],
    '!<2'   => ['[not(position()<2)]', {:start? => false, :end? => true}],
    '!<2^'  => ['[not(position()<2)]', {:start? => true, :end? => false}],
    '!<2$'  => ['[not(position()<2)]', {:start? => false, :end? => true}],
  }

  valid_scope_args = %w{// /awe/some/ //awesome/ //awe/some/}

  describe '> default' do
    {
      :greedy             => [true, 'true'],
      :comparison         => ['=', '='],
      :case_sensitive     => [true, 'true'],
      :match_ordering     => [true, 'true'],
      :include_inner_text => [true, 'true'],
      :normalize_space    => [true, 'true'],
      :scope              => ['//', '//'],
      :position           => [nil, nil],
      :axial_node         => ['self::*', 'self::*'],
      :element_matcher    => [XPathBaker::Matchers::Element, 'XPathBaker::Matchers::Element'],
      :attribute_matcher  => [XPathBaker::Matchers::Attribute, 'XPathBaker::Matchers::Attribute'],
      :text_matcher       => [XPathBaker::Matchers::Text, 'XPathBaker::Matchers::Text'],
      :any_text_matcher   => [XPathBaker::Matchers::AnyText, 'XPathBaker::Matchers::AnyText'],
      :literal_matcher    => [XPathBaker::Matchers::Literal, 'XPathBaker::Matchers::Literal'],
      :group_matcher      => [XPathBaker::Matchers::Group, 'XPathBaker::Matchers::Group'],
    }.each do |setting, (val, display_val)|
      should "have :#{setting} as #{display_val}" do
        XPathBaker.configure {|config| config.send(setting).should.equal val }
      end
    end
  end

  describe '> configuring (with valid values)' do
    {
      :greedy             => [true, false],
      :case_sensitive     => [true, false],
      :match_ordering     => [true, false],
      :include_inner_text => [true, false],
      :normalize_space    => [true, false],
      :scope              => valid_scope_args,
    }.each do |setting, vals|
      should "be able to change :#{setting}" do
        XPathBaker.configure do |config|
          vals.each do |val|
            config.send(:"#{setting}=", val)
            config.send(:"#{setting}").should.equal val
          end
        end
      end
    end

    should 'be able to change :position' do
      XPathBaker.configure do |config|
        valid_position_args.merge(nil => [nil, {}]).each do |val, (expected, test_meths)|
          config.position = val
          config.position.should.equal(expected)
          test_meths.each{|meth, val| config.position.send(meth).should.equal(val) }
        end
      end
    end

    should 'be able to change :comparison' do
      XPathBaker.configure do |config|
        valid_comparison_args.each do |val, (expected, test_meths)|
          config.comparison = val
        puts "before #{val} / #{expected} / #{config.comparison}"
          config.comparison.should.equal(expected)
          test_meths.each{|meth, val| config.comparison.send(meth).should.equal(val) }
        end
      end
    end

    should 'be able to change :axial_node' do
      XPathBaker.configure do |config|
        valid_axial_node_args.each do |val, expected|
          config.axial_node = val
          config.axial_node.should.equal expected
        end
      end
    end

  end

  describe '> configuring (with invalid values)' do
    {
      :greedy             => ['aa', 0, 1, 'be boolean true/false'],
      :case_sensitive     => ['aa', 0, 1, 'be boolean true/false'],
      :match_ordering     => ['aa', 0, 1, 'be boolean true/false'],
      :include_inner_text => ['aa', 0, 1, 'be boolean true/false'],
      :normalize_space    => ['aa', 0, 1, 'be boolean true/false'],
      :scope              => ['boo', '/boo', '//boo', "start & end with '/'"],
      :comparison         => [
        '=!', 'not_eql', 'not_eq', 'aa', 'match any of the following: %s or %s' % [%w{
          = != > !> < !< >= !>= <= !<= ! eq neq gt ngt gte ngte lt nlt lte nlte not equal not_equal
          greater_than not_greater_than greater_than_or_equal not_greater_than_or_equal
          less_than not_less_than less_than_or_equal
        }.join(', '), 'not_less_than_or_equal']
      ],
      :position           => [
        '$', '!$', '^', '!^', '0^', '!0^', '0$', '!0$', 'aa', '02', '!=2',
        '!>=02', '!-2', '!2^$', '2$^', '!!2',
        'match any of the following: %s or %s' % [
          '(1) nil or any integer (0 & nil are taken as no position specified)',
          '(2) /^(!)?(>|>=|<|<=)?([1-9]\d*)(\^|\$)?$/'
        ]
      ],
      :axial_node               => [
        'aa', 'self::watever:', 'aa::', 'match any of the following: %s or %s' % [[
          :ancestor, 'ancestor', 'ancestor::*', /^ancestor::\w+$/,
          :ancestor_or_self, 'ancestor-or-self', 'ancestor-or-self::*', /^ancestor-or-self::\w+$/,
          :attribute, 'attribute', 'attribute::*', /^attribute::\w+$/,
          :child, 'child', 'child::*', /^child::\w+$/,
          :descendant, 'descendant', 'descendant::*', /^descendant::\w+$/,
          :descendant_or_self, 'descendant-or-self', 'descendant-or-self::*', /^descendant-or-self::\w+$/,
          :following, 'following', 'following::*', /^following::\w+$/,
          :following_sibling, 'following-sibling', 'following-sibling::*', /^following-sibling::\w+$/,
          :namespace, 'namespace', 'namespace::*', /^namespace::\w+$/,
          :parent, 'parent', 'parent::*', /^parent::\w+$/,
          :preceding, 'preceding', 'preceding::*', /^preceding::\w+$/,
          :preceding_sibling, 'preceding-sibling', 'preceding-sibling::*', /^preceding-sibling::\w+$/,
          :self, 'self', 'self::*'
        ].join(', '), /^self::\w+$/]
      ]
    }.each do |setting, args|
      vals, msg = args[0..-2], args[-1]
      should "raise XPathBaker::InvalidConfigSettingValueError when :#{setting} is assigned invalid value" do
        XPathBaker.configure do |config|
          full_msg = "Config setting :#{setting} must %s !!" % msg
          vals.each do |val|
            lambda { config.send(:"#{setting}=", val) }.
              should.raise(XPathBaker::InvalidConfigSettingValueError).
              message.should.equal(full_msg)
          end
        end
      end
    end
  end

  describe '> configuring (with reset mode)' do
    {
      :greedy             => [true, val = false, val],
      :case_sensitive     => [true, val = false, val],
      :match_ordering     => [true, val = false, val],
      :include_inner_text => [true, val = false, val],
      :normalize_space    => [true, val = false, val],
      :scope              => ['//', val = '/', val],
      :comparison         => ['=', val = '=', val],
      :position           => [nil, 10, '[10]'],
      :axial_node         => ['self::*', val = 'following::*', val],
      :attribute_matcher  => [XPathBaker::Matchers::Attribute, val = Class.new{ A = 1 }, val],
      :text_matcher       => [XPathBaker::Matchers::Text, val = Class.new{ B = 1 }, val],
      :literal_matcher    => [XPathBaker::Matchers::Literal, val = Class.new{ C = 1 }, val],
      :group_matcher      => [XPathBaker::Matchers::Group, val = Class.new{ D = 1 }, val],
      :any_text_matcher   => [XPathBaker::Matchers::AnyText, val = Class.new{ E = 1 }, val],
      :element_matcher    => [XPathBaker::Matchers::Element, val = Class.new{ F = 1 }, val],
    }.each do |setting, (default_val, assigned_custom_val, expected_custom_val)|

      should "revert customized :#{setting} to default (when no block is given)" do
        XPathBaker.configure {|config| config.send(:"#{setting}=", assigned_custom_val) }
        XPathBaker.configure(:reset)
        XPathBaker.configure {|config| config.send(:"#{setting}").should.equal default_val }
      end

      should "set customized :#{setting} to specified value (when block is given)" do
        XPathBaker.configure(:reset) {|config| config.send(:"#{setting}=", assigned_custom_val) }
        XPathBaker.configure {|config| config.send(:"#{setting}").should.equal expected_custom_val }
      end

    end
  end

  describe '> configuring (with invalid mode)' do
    should 'raise XPathBaker::InvalidConfigModeError' do
      lambda { XPathBaker.configure(:watever) }.
        should.raise(XPathBaker::InvalidConfigModeError).
        message.should.equal('Config mode :watever is not supported !!')
    end
  end

  describe '> converting to hash' do
    should 'return configured settings as a hash' do
      XPathBaker::Configuration.to_hash.should.equal XPathBaker::Configuration::DEFAULT_SETTINGS
    end
  end

  describe '> determining if an object describes configuration' do

    should 'return false if something is not neither a Hash nor an Array' do
      [:something, 'something', /something/, Object.new].each do |something|
        XPathBaker::Configuration.describes_config?(something).should.be.false
      end
    end

    {
      'Array' => [%w{!n x},%w{!n //boo/ self::*}, []],
      'Hash'  => [{:position => nil, :watever => false},{:position => nil, :scope => '//boo/'}, {}]
    }.each do |type, (invalid, valid, empty)|

      should "return false if something is #{type} but not all contents are config settings" do
        XPathBaker::Configuration.describes_config?(invalid).should.be.false
      end

      should "return true if something is #{type} and all contents are config settings" do
        XPathBaker::Configuration.describes_config?(valid).should.be.true
      end

      should "return true if something is an empty #{type}" do
        XPathBaker::Configuration.describes_config?(empty).should.be.true
      end

    end

  end

  describe '> normalizing non-default format configuration (w array)' do

    {
       :greedy             => {'g' => true, '!g' => false},
       :case_sensitive     => {'c' => true, '!c' => false},
       :match_ordering     => {'o' => true, '!o' => false},
       :normalize_space    => {'n' => true, '!n' => false},
       :include_inner_text => {'i' => true, '!i' => false},
    }.each do |setting, val_vs_expected|
      should "be able to normalize :#{setting} setting" do
        val_vs_expected.each do |val, expected|
          XPathBaker::Configuration.normalize([val]).should.equal({setting => expected})
        end
      end
    end

    {
      :axial_node => valid_axial_node_args.values,
      :scope => valid_scope_args
    }.each do |setting, vals|
      should "be able to normalize :#{setting} setting" do
        vals.each{|val| XPathBaker::Configuration.normalize([val]).should.equal({setting => val}) }
      end
    end

    {
      :group_matcher => [[XPathBaker::Matchers::Group, 'XPathBaker::Matchers::Group'], XPathBaker::Matchers::Group],
      :any_text_matcher => [[XPathBaker::Matchers::AnyText, 'XPathBaker::Matchers::AnyText'], XPathBaker::Matchers::AnyText],
      :element_matcher => [[XPathBaker::Matchers::Element, 'XPathBaker::Matchers::Element'], XPathBaker::Matchers::Element],
      :attribute_matcher => [[XPathBaker::Matchers::Attribute, 'XPathBaker::Matchers::Attribute'], XPathBaker::Matchers::Attribute],
      :literal_matcher => [[XPathBaker::Matchers::Literal, 'XPathBaker::Matchers::Literal'], XPathBaker::Matchers::Literal],
      :text_matcher => [[XPathBaker::Matchers::Text, 'XPathBaker::Matchers::Text'], XPathBaker::Matchers::Text],
    }.each do |setting, (vals, expected)|
      should "be able to normalize :#{setting} setting" do
        vals.each{|val| XPathBaker::Configuration.normalize([val]).should.equal({setting => expected}) }
      end
    end

    should 'be able to normalize :position setting' do
      valid_position_args.keys.each do |val|
        XPathBaker::Configuration.normalize([val]).should.equal({:position => val.to_s})
      end
    end

    should 'be able to normalize :comparison setting' do
      valid_comparison_args.keys.reject{|key| key.is_a?(Symbol) }.each do |val|
        XPathBaker::Configuration.normalize([val]).should.equal({:comparison => val})
      end
    end

    should 'raise XPathBaker::ConfigSettingNotSupportedError if setting cannot be normalized' do
      [
        '$', '!$', '^', '!^', '0^', '!0^', '0$', '!0$', 'aa', '02', '!=2',
        '!>=02', '!-2', '!2^$', '2$^', '!!2', 'aa', 'self::watever:', 'aa::',
        'awe/some', '//awe/some', 'awe/some', 'x', '!x'
      ].each do |val|
        lambda { XPathBaker::Configuration.normalize([val]) }.
          should.raise(XPathBaker::InvalidConfigSettingValueError).
          message.should.equal("Config setting value '#{val}' cannot be mapped to any supported settings !!")
      end
    end

  end

  describe '> normalizing non-default format configuration (w hash)' do
    should 'return arg as it is' do
      XPathBaker::Configuration.normalize(arg = {:aa => 1}).should.equal(arg)
    end
  end

  describe '> normalizing non-default format configuration (w non array/hash)' do
    should 'raise XPathBaker::InvalidArgumentError' do
      [nil, Object.new, 1, '1'].each do |arg|
        lambda { XPathBaker::Configuration.normalize(arg) }.
          should.raise(XPathBaker::InvalidArgumentError).
          message.should.equal('Config normalizing can ONLY be done for Array/Hash !!')
      end
    end
  end

  describe '> getting a new configuration (w hash)' do

    should 'duplicate a copy of itself' do
      configuration = XPathBaker::Configuration.new({})
      configuration.to_hash.should.equal XPathBaker::Configuration.to_hash
      configuration.object_id.should.not.equal XPathBaker::Configuration
    end

    should 'have hash overrides its settings' do
      orig_settings = XPathBaker::Configuration.to_hash
      normalize_space_val = {true => false, false => true}[orig_settings[:normalize_space]]
      configuration = XPathBaker::Configuration.new(:normalize_space => normalize_space_val)
      configuration.to_hash.should.equal orig_settings.merge(:normalize_space => normalize_space_val)
    end

    should 'raise XPathBaker::ConfigSettingNotSupportedError if unsupported setting is specified' do
      lambda { XPathBaker::Configuration.new(:hello => 'ee') }.
        should.raise(XPathBaker::ConfigSettingNotSupportedError).
        message.should.equal('Config setting :hello is not supported !!')
    end

    should 'raise XPathBaker::InvalidConfigSettingValueError if setting is assigned invalid value' do
      lambda { XPathBaker::Configuration.new(:case_sensitive => 'ee') }.
        should.raise(XPathBaker::InvalidConfigSettingValueError).
        message.should.equal('Config setting :case_sensitive must be boolean true/false !!')
    end

  end

  describe '> getting a new configuration (w array)' do

    should 'duplicate a copy of itself' do
      configuration = XPathBaker::Configuration.new([])
      configuration.to_hash.should.equal XPathBaker::Configuration.to_hash
      configuration.object_id.should.not.equal XPathBaker::Configuration
    end

    should 'have array overrides its settings' do
      orig_settings = XPathBaker::Configuration.to_hash
      normalize_space_val = !orig_settings[:normalize_space]
      configuration = XPathBaker::Configuration.new([{:true => 'n', false => '!n'}[normalize_space_val]])
      configuration.to_hash.should.equal orig_settings.merge(:normalize_space => normalize_space_val)
    end

    # TODO: The following contains some overlappings for specs of #normalize, pls find time
    # to do cleaning up !!

    should 'be able to map valid shorthand settings to their respective verbose counterparts' do
      {
         'g' => [:greedy, true],
        '!g' => [:greedy, false],
         'c' => [:case_sensitive, true],
        '!c' => [:case_sensitive, false],
         'o' => [:match_ordering, true],
        '!o' => [:match_ordering, false],
         'n' => [:normalize_space, true],
        '!n' => [:normalize_space, false],
         'i' => [:include_inner_text, true],
        '!i' => [:include_inner_text, false],
      }.each do |shorthand, (setting, expected)|
        XPathBaker::Configuration.new([shorthand]).to_hash[setting].should.equal(expected)
      end
    end

    {
      :axial_node => valid_axial_node_args.values,
      :scope => valid_scope_args
    }.each do |setting, vals|
      should "be able to extract & assign :#{setting} setting" do
        vals.each{|val| XPathBaker::Configuration.new([val]).to_hash[setting].should.equal(val) }
      end
    end

    {
      :group_matcher => [[XPathBaker::Matchers::Group, 'XPathBaker::Matchers::Group'], XPathBaker::Matchers::Group],
      :any_text_matcher => [[XPathBaker::Matchers::AnyText, 'XPathBaker::Matchers::AnyText'], XPathBaker::Matchers::AnyText],
      :element_matcher => [[XPathBaker::Matchers::Element, 'XPathBaker::Matchers::Element'], XPathBaker::Matchers::Element],
      :attribute_matcher => [[XPathBaker::Matchers::Attribute, 'XPathBaker::Matchers::Attribute'], XPathBaker::Matchers::Attribute],
      :literal_matcher => [[XPathBaker::Matchers::Literal, 'XPathBaker::Matchers::Literal'], XPathBaker::Matchers::Literal],
      :text_matcher => [[XPathBaker::Matchers::Text, 'XPathBaker::Matchers::Text'], XPathBaker::Matchers::Text],
    }.each do |setting, (vals, expected)|
      should "be able to extract & assign :#{setting} setting" do
        vals.each{|val| XPathBaker::Configuration.new([val]).to_hash[setting].should.equal(expected) }
      end
    end

    should 'be able to extract & assign :position setting' do
      valid_position_args.each do |val, expected|
        position = XPathBaker::Configuration.new([val]).to_hash[:position]
        position.should.equal(expected[0])
        expected[1].each{|meth, _val| position.send(meth).should.equal(_val) }
      end
    end

    should 'be able to extract & assign :comparison setting' do
      valid_comparison_args.reject{|key,val| key.is_a?(Symbol) }.each do |val, expected|
        comparison = XPathBaker::Configuration.new([val]).to_hash[:comparison]
        comparison.should.equal(expected[0])
        expected[1].each{|meth, _val| comparison.send(meth).should.equal(_val) }
      end
    end

    should 'raise XPathBaker::ConfigSettingNotSupportedError if setting cannot be identified & assigned' do
      [
        '$', '!$', '^', '!^', '0^', '!0^', '0$', '!0$', 'aa', '02', '!=2',
        '!>=02', '!-2', '!2^$', '2$^', '!!2', 'aa', 'self::watever:', 'aa::',
        'awe/some', '//awe/some', 'awe/some', 'x', '!x'
      ].each do |val|
        lambda { XPathBaker::Configuration.new([val]) }.
          should.raise(XPathBaker::InvalidConfigSettingValueError).
          message.should.equal("Config setting value '#{val}' cannot be mapped to any supported settings !!")
      end
    end

  end

end
