require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "XPF::Configuration" do

  before do
    XPF.configure(:reset)
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
      :case_sensitive     => [true, 'true'],
      :match_ordering     => [true, 'true'],
      :include_inner_text => [true, 'true'],
      :normalize_space    => [true, 'true'],
      :scope              => ['//', '//'],
      :position           => [nil, nil],
      :axial_node         => ['self::*', 'self::*'],
      :attribute_matcher  => [XPF::Matchers::Attribute, 'XPF::Matchers::Attribute'],
      :text_matcher       => [XPF::Matchers::Text, 'XPF::Matchers::Text'],
      :literal_matcher    => [XPF::Matchers::Literal, 'XPF::Matchers::Literal'],
      :group_matcher      => [XPF::Matchers::Group, 'XPF::Matchers::Group'],
    }.each do |setting, (val, display_val)|
      should "have :#{setting} as #{display_val}" do
        XPF.configure {|config| config.send(setting).should.equal val }
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
        XPF.configure do |config|
          vals.each do |val|
            config.send(:"#{setting}=", val)
            config.send(:"#{setting}").should.equal val
          end
        end
      end
    end

    should 'be able to change :position' do
      XPF.configure do |config|
        valid_position_args.merge(nil => [nil, {}]).each do |val, (expected, test_meths)|
          config.position = val
          config.position.should.equal(expected)
          test_meths.each{|meth, val| config.position.send(meth).should.equal(val) }
        end
      end
    end

    should 'be able to change :axial_node' do
      XPF.configure do |config|
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
      :position           => [
        '$', '!$', '^', '!^', '!', '0^', '!0^', '0$', '!0$', 'aa', '02', '!=2',
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
      should "raise XPF::InvalidConfigSettingValueError when :#{setting} is assigned invalid value" do
        XPF.configure do |config|
          full_msg = "Config setting :#{setting} must %s !!" % msg
          vals.each do |val|
            lambda { config.send(:"#{setting}=", val) }.
              should.raise(XPF::InvalidConfigSettingValueError).
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
      :position           => [nil, 10, '[10]'],
      :axial_node         => ['self::*', val = 'following::*', val],
      :attribute_matcher  => [XPF::Matchers::Attribute, val = Class.new{ A = 1 }, val],
      :text_matcher       => [XPF::Matchers::Text, val = Class.new{ B = 1 }, val],
      :literal_matcher    => [XPF::Matchers::Literal, val = Class.new{ C = 1 }, val],
      :group_matcher      => [XPF::Matchers::Group, val = Class.new{ D = 1 }, val],
    }.each do |setting, (default_val, assigned_custom_val, expected_custom_val)|

      should "revert customized :#{setting} to default (when no block is given)" do
        XPF.configure {|config| config.send(:"#{setting}=", assigned_custom_val) }
        XPF.configure(:reset)
        XPF.configure {|config| config.send(:"#{setting}").should.equal default_val }
      end

      should "set customized :#{setting} to specified value (when block is given)" do
        XPF.configure(:reset) {|config| config.send(:"#{setting}=", assigned_custom_val) }
        XPF.configure {|config| config.send(:"#{setting}").should.equal expected_custom_val }
      end

    end
  end

  describe '> configuring (with invalid mode)' do
    should 'raise XPF::InvalidConfigModeError' do
      lambda { XPF.configure(:watever) }.
        should.raise(XPF::InvalidConfigModeError).
        message.should.equal('Config mode :watever is not supported !!')
    end
  end

  describe '> converting to hash' do
    should 'return configured settings as a hash' do
      XPF::Configuration.to_hash.should.equal XPF::Configuration::DEFAULT_SETTINGS
    end
  end

  describe '> determining if an object describes configuration' do

    should 'return false if something is not neither a Hash nor an Array' do
      [:something, 'something', /something/, Object.new].each do |something|
        XPF::Configuration.describes_config?(something).should.be.false
      end
    end

    {
      'Array' => [%w{!n x},%w{!n //boo/ self::*}, []],
      'Hash'  => [{:position => nil, :watever => false},{:position => nil, :scope => '//boo/'}, {}]
    }.each do |type, (invalid, valid, empty)|

      should "return false if something is #{type} but not all contents are config settings" do
        XPF::Configuration.describes_config?(invalid).should.be.false
      end

      should "return true if something is #{type} and all contents are config settings" do
        XPF::Configuration.describes_config?(valid).should.be.true
      end

      should "return true if something is an empty #{type}" do
        XPF::Configuration.describes_config?(empty).should.be.true
      end

    end

  end

  describe '> getting a new configuration (w hash)' do

    should 'duplicate a copy of itself' do
      configuration = XPF::Configuration.new({})
      configuration.to_hash.should.equal XPF::Configuration.to_hash
      configuration.object_id.should.not.equal XPF::Configuration
    end

    should 'have hash overrides its settings' do
      orig_settings = XPF::Configuration.to_hash
      normalize_space_val = {true => false, false => true}[orig_settings[:normalize_space]]
      configuration = XPF::Configuration.new(:normalize_space => normalize_space_val)
      configuration.to_hash.should.equal orig_settings.merge(:normalize_space => normalize_space_val)
    end

    should 'raise XPF::ConfigSettingNotSupportedError if unsupported setting is specified' do
      lambda { XPF::Configuration.new(:hello => 'ee') }.
        should.raise(XPF::ConfigSettingNotSupportedError).
        message.should.equal('Config setting :hello is not supported !!')
    end

    should 'raise XPF::InvalidConfigSettingValueError if setting is assigned invalid value' do
      lambda { XPF::Configuration.new(:case_sensitive => 'ee') }.
        should.raise(XPF::InvalidConfigSettingValueError).
        message.should.equal('Config setting :case_sensitive must be boolean true/false !!')
    end

  end

  describe '> getting a new configuration (w array)' do

    should 'duplicate a copy of itself' do
      configuration = XPF::Configuration.new([])
      configuration.to_hash.should.equal XPF::Configuration.to_hash
      configuration.object_id.should.not.equal XPF::Configuration
    end

    should 'have array overrides its settings' do
      orig_settings = XPF::Configuration.to_hash
      normalize_space_val = !orig_settings[:normalize_space]
      configuration = XPF::Configuration.new([{:true => 'n', false => '!n'}[normalize_space_val]])
      configuration.to_hash.should.equal orig_settings.merge(:normalize_space => normalize_space_val)
    end

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
        XPF::Configuration.new([shorthand]).to_hash[setting].should.equal(expected)
      end
    end

    {
      :axial_node => valid_axial_node_args.values,
      :scope => valid_scope_args
    }.each do |setting, vals|
      should "be able to extract & assign :#{setting} setting" do
        vals.each{|val| XPF::Configuration.new([val]).to_hash[setting].should.equal(val) }
      end
    end

    {
      :group_matcher => [[XPF::Matchers::Group, 'XPF::Matchers::Group'], XPF::Matchers::Group],
      :attribute_matcher => [[XPF::Matchers::Attribute, 'XPF::Matchers::Attribute'], XPF::Matchers::Attribute],
      :literal_matcher => [[XPF::Matchers::Literal, 'XPF::Matchers::Literal'], XPF::Matchers::Literal],
      :text_matcher => [[XPF::Matchers::Text, 'XPF::Matchers::Text'], XPF::Matchers::Text],
    }.each do |setting, (vals, expected)|
      should "be able to extract & assign :#{setting} setting" do
        vals.each{|val| XPF::Configuration.new([val]).to_hash[setting].should.equal(expected) }
      end
    end

    should 'be able to extract & assign :position setting' do
      valid_position_args.each do |val, expected|
        position = XPF::Configuration.new([val]).to_hash[:position]
        position.should.equal(expected[0])
        expected[1].each{|meth, _val| position.send(meth).should.equal(_val) }
      end
    end

    should 'raise XPF::ConfigSettingNotSupportedError if setting cannot be identified & assigned' do
      [
        '$', '!$', '^', '!^', '!', '0^', '!0^', '0$', '!0$', 'aa', '02', '!=2',
        '!>=02', '!-2', '!2^$', '2$^', '!!2', 'aa', 'self::watever:', 'aa::',
        'awe/some', '//awe/some', 'awe/some', 'x', '!x'
      ].each do |val|
        lambda { XPF::Configuration.new([val]) }.
          should.raise(XPF::InvalidConfigSettingValueError).
          message.should.equal("Config setting value '#{val}' cannot be mapped to any supported settings !!")
      end
    end

  end

end
