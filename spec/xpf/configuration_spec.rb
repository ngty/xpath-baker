require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "XPF::Configuration" do

  describe '> default' do
    {
      :case_sensitive     => [true, 'true'],
      :match_ordering     => [true, 'true'],
      :include_inner_text => [true, 'true'],
      :normalize_space    => [true, 'true'],
      :position           => [nil, 'nil'],
      :axis               => [:self, ':self']
    }.each do |setting, args|
      val, display_val = args
      should "have :#{setting} as #{display_val}" do
        XPF.configure {|config| config.send(setting).should.equal val }
      end
    end
  end

  describe '> configuring (with valid values)' do
    {
      :case_sensitive     => [true, false],
      :match_ordering     => [true, false],
      :include_inner_text => [true, false],
      :normalize_space    => [true, false],
      :position           => [nil, 1, 10],
      :axis               => %w{
        ancestor ancestor_or_self child descendant descendant_or_self following
        following_sibling namespace parent preceding preceding_sibling self
      }.map(&:to_sym)
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
  end

  describe '> configuring (with invalid values)' do
    {
      :case_sensitive     => ['aa', 'boolean true/false'],
      :match_ordering     => ['aa', 'boolean true/false'],
      :include_inner_text => ['aa', 'boolean true/false'],
      :normalize_space    => ['aa', 'boolean true/false'],
      :position           => ['aa', 0, 'nil or a non-zero integer'],
      :axis               => [
        'aa', 'any of :%s & :%s' % [%w{
          ancestor ancestor_or_self child descendant descendant_or_self following
          following_sibling namespace parent preceding preceding_sibling
        }.join(', :'), 'self']
      ]
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

#  describe '> merging with a settings hash' do
#
#    before do
#      @orig_settings = {
#        :normalize_space => 'aa',
#        :include_inner_text => 'bb',
#        :match_ordering => 'cc',
#        :case_sensitive => 'dd',
#        :position => 'ee'
#      }
#      @orig_settings.each {|setting, val| XPF::Configuration.send(:"#{setting}=", val) }
#      @should_have_equal_settings = lambda do |configuration, expected_hash|
#        expected_hash.each {|setting, val| configuration.send(setting).should == val }
#      end
#    end
#
#    should 'duplicate a copy of itself' do
#      configuration = XPF::Configuration.merge({})
#      @should_have_equal_settings[configuration, @orig_settings]
#      configuration.object_id.should.not.equal XPF::Configuration
#    end
#
#    should 'have hash overrides its settings' do
#      configuration = XPF::Configuration.merge(settings_hash = {:normalize_space => 'ee'})
#      @should_have_equal_settings[configuration, @orig_settings.merge(settings_hash)]
#    end
#
#    should 'raise XPF::ConfigSettingNotSupportedError if unsupported setting is specified' do
#      lambda { XPF::Configuration.merge(:hello => 'ee') }.
#        should.raise(XPF::ConfigSettingNotSupportedError).
#        message.should.equal('Config setting :hello is not supported !!')
#    end
#
#  end

end
