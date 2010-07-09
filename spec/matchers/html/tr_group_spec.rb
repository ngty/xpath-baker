require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'generic', 'basic_group_shared_spec')
require 'xpath-baker/html'

describe "XPathBaker::HTML::Matchers::TR::Group" do

  before do
    XPathBaker.configure(:reset){|config| config.axial_node = 'self::*' }
    @matcher_klass = XPathBaker::HTML::Matchers::TR::Group
    @new_matcher = lambda do |match_attrs, config|
      @matcher_klass.new(match_attrs, XPathBaker::Configuration.new(config))
    end
    @condition_should_equal = lambda do |match_attrs, config, expected|
      @new_matcher[match_attrs, config].condition.should.equal(expected)
    end
  end

  after do
    XPathBaker.configure(:reset)
  end

  shared 'stubbing in action' do

    before do
      # NOTE: In short, stubbing in action ..
      XPathBaker::HTML::Matchers::TR::Group.class_eval do
        alias_method :orig_new_typed_matcher, :new_typed_matcher
        def new_typed_matcher(val, config)
          (matcher = orig_new_typed_matcher(val, config)).instance_eval do
            def condition
              '((matcher:%s:%s,%s))' % [
                self.class.to_s.downcase.split('::').last,
                diffentiable_val(value), diffentiable_val(config)
              ]
            end
          end
          matcher
        end
      end
    end

    after do
      XPathBaker::HTML::Matchers::TR::Group.class_eval do
        alias_method :new_typed_matcher, :orig_new_typed_matcher
      end
    end

  end

  describe '> generating condition (w valid {:tds => {...}})' do

    behaves_like 'stubbing in action'

    before do
      @tds = {:th1 => 'td1', :th2 => 'td2'}
    end

    should 'return expr reflecting hash entries' do
      expected = '((matcher:hash:%s,))' % diffentiable_val(@tds)
      @condition_should_equal[{:tds => @tds}, {}, expected]
    end

    valid_config_settings_args(
      :greedy, :match_ordering, :case_sensitive, :include_inner_text, :normalize_space, :comparison,
      :scope, :position, :element_matcher, :attribute_matcher, :text_matcher, :literal_matcher,
      :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each do |config|
          next unless config.is_a?(Hash)
          expected = '((matcher:hash:%s,%s))' % [diffentiable_val(@tds), dump_config(config)]
          @condition_should_equal[{:tds => @tds}, config, expected]
        end
      end
    end

  end

  describe '> generating condition (w valid {:tds => [...]})' do

    behaves_like 'stubbing in action'

    before do
      @tds = %w{td1 td2}
    end

    should 'return expr reflecting array entries' do
      expected = '((matcher:array:%s,))' % diffentiable_val(@tds)
      @condition_should_equal[{:tds => @tds}, {}, expected]
    end

    valid_config_settings_args(
      :greedy, :match_ordering, :case_sensitive, :include_inner_text, :normalize_space, :comparison,
      :scope, :position, :element_matcher, :attribute_matcher, :text_matcher, :literal_matcher,
      :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each do |config|
          next unless config.is_a?(Hash)
          expected = '((matcher:array:%s,%s))' % [diffentiable_val(@tds), dump_config(config)]
          @condition_should_equal[{:tds => @tds}, config, expected]
        end
      end
    end

  end

  describe '> generating condition (w valid [:tds, ...])' do

    behaves_like 'stubbing in action'

    should 'return expr reflecting presence of child <td/>' do
      @condition_should_equal[[:tds], {}, '((matcher:nil:XPathBaker_NIL_VALUE,))']
    end

    valid_config_settings_args(
      :greedy, :match_ordering, :case_sensitive, :include_inner_text, :normalize_space, :comparison,
      :scope, :position, :element_matcher, :attribute_matcher, :text_matcher, :literal_matcher,
      :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each do |config|
          next unless config.is_a?(Hash)
          expected = '((matcher:nil:XPathBaker_NIL_VALUE,%s))' % [dump_config(config)]
          @condition_should_equal[[:tds], config, expected]
        end
      end
    end

  end

  describe '> generating condition (w invalid {:tds => ...})' do

    should 'raise XPathBaker::InvalidMatchAttrError when value is not a supported type' do
      ['aa', nil, 1, Object.new].each do |val|
        lambda{ @new_matcher[{:tds => val}, {}] }.
          should.raise(XPathBaker::InvalidMatchAttrError).
          message.should.equal('Match attribute :tds must be a Hash or Array !!')
      end
    end

  end

  before { @matcher_klass = XPathBaker::HTML::Matchers::TR::Group }
  behaves_like 'basic group matcher'

end
