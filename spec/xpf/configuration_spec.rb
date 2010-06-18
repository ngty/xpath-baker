require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "XPF::Configuration" do

  describe '> default' do
    {
      :greedy             => [true, 'true'],
      :case_sensitive     => [true, 'true'],
      :match_ordering     => [true, 'true'],
      :include_inner_text => [true, 'true'],
      :normalize_space    => [true, 'true'],
      :scope              => ['//', '//'],
      :position           => [nil, nil],
      :axis               => ['self::*', 'self::*'],
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
      :scope              => ['/', '//awe/some'],
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
        {
          0       => [nil, {}],
          2       => ['[2]', {:start? => false, :end? => true}],
          '2^'    => ['[2]', {:start? => true, :end? => false}],
          '2$'    => ['[2]', {:start? => false, :end? => true}],
          '=2'    => ['[2]', {:start? => false, :end? => true}],
          '=2^'   => ['[2]', {:start? => true, :end? => false}],
          '=2$'   => ['[2]', {:start? => false, :end? => true}],
          '!=2'   => ['[position()!=2]', {:start? => false, :end? => true}],
          '!=2^'  => ['[position()!=2]', {:start? => true, :end? => false}],
          '!=2$'  => ['[position()!=2]', {:start? => false, :end? => true}],
          '1!~2'  => ['[not(position()>=1 and position()<=2)]', {:start? => false, :end? => true}],
          '1!~2^' => ['[not(position()>=1 and position()<=2)]', {:start? => true, :end? => false}],
          '1!~2$' => ['[not(position()>=1 and position()<=2)]', {:start? => false, :end? => true}],
          '1~2'   => ['[position()>=1 and position()<=2]', {:start? => false, :end? => true}],
          '1~2^'  => ['[position()>=1 and position()<=2]', {:start? => true, :end? => false}],
          '1~2$'  => ['[position()>=1 and position()<=2]', {:start? => false, :end? => true}],
          '>=2'   => ['[position()>=2]', {:start? => false, :end? => true}],
          '>=2^'  => ['[position()>=2]', {:start? => true, :end? => false}],
          '>=2$'  => ['[position()>=2]', {:start? => false, :end? => true}],
          '>2'    => ['[position()>2]', {:start? => false, :end? => true}],
          '>2^'   => ['[position()>2]', {:start? => true, :end? => false}],
          '>2$'   => ['[position()>2]', {:start? => false, :end? => true}],
          '<=2'   => ['[position()<=2]', {:start? => false, :end? => true}],
          '<=2^'  => ['[position()<=2]', {:start? => true, :end? => false}],
          '<=2$'  => ['[position()<=2]', {:start? => false, :end? => true}],
          '<2'    => ['[position()<2]', {:start? => false, :end? => true}],
          '<2^'   => ['[position()<2]', {:start? => true, :end? => false}],
          '<2$'   => ['[position()<2]', {:start? => false, :end? => true}],
        }.each do |val, (expected, test_meths)|
          config.position = val
          config.position.should.equal(expected)
          test_meths.each{|meth, val| config.position.send(meth).should.equal(val) }
        end
      end
    end

    should 'be able to change :axis' do
      XPF.configure do |config|
        {
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
        }.each do |val, expected|
          config.axis = val
          config.axis.should.equal expected
        end
      end
    end

  end

  describe '> configuring (with invalid values)' do
    {
      :greedy             => ['aa', 'boolean true/false'],
      :case_sensitive     => ['aa', 'boolean true/false'],
      :match_ordering     => ['aa', 'boolean true/false'],
      :include_inner_text => ['aa', 'boolean true/false'],
      :normalize_space    => ['aa', 'boolean true/false'],
      #:position           => ['aa', nil, 'nil or a non-zero integer'],
      #:axis               => [
      #   'aa', 'any of :%s & :%s' % [%w{
      #     ancestor ancestor_or_self child descendant descendant_or_self following
      #     following_sibling namespace parent preceding preceding_sibling
      #   }.join(', :'), 'self']
      # ]
    }.each do |setting, args|
      vals, msg = args[0..-2], args[-1]
      should "raise XPF::InvalidConfigSettingValueError when :#{setting} is assigned invalid value" do
        XPF.configure do |config|
          full_msg = "Config setting :#{setting} must be %s !!" % msg
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
      :greedy             => [true, false],
      :case_sensitive     => [true, false],
      :match_ordering     => [true, false],
      :include_inner_text => [true, false],
      :normalize_space    => [true, false],
      :scope              => ['//', '/'],
      #:position           => [nil, 10],
      #:axis               => [:self, :following],
    }.each do |setting, args|
      default_val, custom_val = args
      should "revert customized :#{setting} to default" do
        XPF.configure {|config| config.send(:"#{setting}=", custom_val) }
        XPF.configure(:reset)
        XPF.configure {|config| config.send(:"#{setting}").should.equal default_val }
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

#  describe '> converting to hash' do
#    should 'return configured settings as a hash' do
#      XPF::Configuration.to_hash.should.equal XPF::Configuration::DEFAULT_SETTINGS
#    end
#  end

  describe '> getting a new configuration' do

    should 'duplicate a copy of itself' do
      configuration = XPF::Configuration.new({})
      configuration.to_hash.should.equal XPF::Configuration.to_hash
      configuration.object_id.should.not.equal XPF::Configuration
    end

    should 'have hash overrides its settings' do
      orig_settings = XPF::Configuration.to_hash
      normalize_space_val = !orig_settings[:normalize_space]
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

end
