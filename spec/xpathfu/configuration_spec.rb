require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "XPathFu Configuration" do

  describe '> default' do

    should 'have :case_sensitive as true' do
      XPathFu.configure {|config| config.case_sensitive.should.be.true }
    end

    should 'have :match_ordering as true' do
      XPathFu.configure {|config| config.match_ordering.should.be.true }
    end

    should 'have :include_inner_text as true' do
      XPathFu.configure {|config| config.include_inner_text.should.be.true }
    end

    should 'have :normalize_space as true' do
      XPathFu.configure {|config| config.normalize_space.should.be.true }
    end

  end

  describe '> configuring' do

    should 'be able to change :case_sensitive' do
      XPathFu.configure do |config|
        config.case_sensitive = false
        config.case_sensitive.should.be.false
        config.case_sensitive = true
        config.case_sensitive.should.be.true
      end
    end

    should 'be able to change :match_ordering' do
      XPathFu.configure do |config|
        config.match_ordering = false
        config.match_ordering.should.be.false
        config.match_ordering = true
        config.match_ordering.should.be.true
      end
    end

    should 'be able to change :include_inner_text' do
      XPathFu.configure do |config|
        config.include_inner_text = false
        config.include_inner_text.should.be.false
        config.include_inner_text = true
        config.include_inner_text.should.be.true
      end
    end

    should 'be able to change :normalize_space' do
      XPathFu.configure do |config|
        config.normalize_space = false
        config.normalize_space.should.be.false
        config.normalize_space = true
        config.normalize_space.should.be.true
      end
    end

  end

  describe '> merging with a settings hash' do

    before do
      @orig_settings = {
        :normalize_space => 'aa',
        :include_inner_text => 'bb',
        :match_ordering => 'cc',
        :case_sensitive => 'dd'
      }
      @orig_settings.each {|setting, val| XPathFu::Configuration.send(:"#{setting}=", val) }
      @should_have_equal_settings = lambda do |configuration, expected_hash|
        expected_hash.each {|setting, val| configuration.send(setting).should == val }
      end
    end

    should 'duplicate a copy of itself' do
      configuration = XPathFu::Configuration.merge({})
      @should_have_equal_settings[configuration, @orig_settings]
      configuration.object_id.should.not.equal XPathFu::Configuration
    end

    should 'have hash overrides its settings' do
      configuration = XPathFu::Configuration.merge(settings_hash = {:normalize_space => 'ee'})
      @should_have_equal_settings[configuration, @orig_settings.merge(settings_hash)]
    end

    should 'raise XPathFu::ConfigSettingNotSupportedError if unsupported setting is specified' do
      lambda { XPathFu::Configuration.merge(:hello => 'ee') }.
        should.raise(XPathFu::ConfigSettingNotSupportedError).
        message.should.equal('Config setting :hello is not supported !!')
    end

  end

end