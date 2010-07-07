shared 'a basic text matcher' do

  describe '> generating condition (with string value)' do

    before do
      @val = 'text-x'
      @default = %|normalize-space(.)="#{@val}"|
      @condition_should_equal = lambda do |config, expected|
        @text_matcher.new(@val, XPF::Configuration.new(config)).condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      @condition_should_equal[{:normalize_space => false}, %|.="#{@val}"|]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      expected = [translate_casing('normalize-space(.)'), %|"#{@val.upcase}"|].join('=')
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

    should 'include inner text when config[:include_inner_text] is true' do
      @condition_should_equal[{:include_inner_text => true}, @default]
    end

    should 'not include inner text when config[:include_inner_text] is false' do
      @condition_should_equal[{:include_inner_text => false}, %|normalize-space(text())="#{@val}"|]
    end

    should 'apply comparison as specified by config[:comparison]' do
      {
        '!'   => 'not(normalize-space(%s)=%s)',
        '='   => 'normalize-space(%s)=%s',
        '!='  => 'not(normalize-space(%s)=%s)',
        '>'   => 'normalize-space(%s)>%s',
        '!>'  => 'not(normalize-space(%s)>%s)',
        '<'   => 'normalize-space(%s)<%s',
        '!<'  => 'not(normalize-space(%s)<%s)',
        '>='  => 'normalize-space(%s)>=%s',
        '!>=' => 'not(normalize-space(%s)>=%s)',
        '<='  => 'normalize-space(%s)<=%s',
        '!<=' => 'not(normalize-space(%s)<=%s)',
      }.each do |op, expected|
        @condition_should_equal[{:comparison => op}, expected % ['.', %|"#{@val}"|]]
      end
    end

    should 'elegantly handle quoting of value with double quote (")' do
      @val = 'text-"x"'
      @condition_should_equal[{}, %|normalize-space(.)=concat("text-",'"',"x",'"',"")|]
    end

    valid_config_settings_args(
      :greedy, :match_ordering, :scope, :position, :axial_node, :element_matcher,
      :attribute_matcher, :text_matcher, :any_text_matcher, :literal_matcher, :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each{|config| @condition_should_equal[config, @default] }
      end
    end

  end

  describe '> generating condition (w single element array value)' do

    before do
      @val = 'text-x'
      @default = check_tokens("normalize-space(.)", [%|"#{@val}"|])
      @condition_should_equal = lambda do |config, expected|
        @text_matcher.new([@val], XPF::Configuration.new(config)).condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      expected = check_tokens(".", [%|"#{@val}"|])
      @condition_should_equal[{:normalize_space => false}, expected]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      expected = check_tokens(translate_casing("normalize-space(.)"), [%|"#{@val.upcase}"|])
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

    should "apply negation when config[:comparison] is any of: !, !=, !>, !<, !>=, !<=" do
      %w{! != !> !>= !< !<=}.each do |op|
        @condition_should_equal[{:comparison => op}, %|not(#{@default})|]
      end
    end

    should 'ignore all other specified config[:comparison]' do
      %w{= > >= < <=}.each do |op|
        @condition_should_equal[{:comparison => op}, @default]
      end
    end

    valid_config_settings_args(
      :greedy, :match_ordering, :scope, :position, :axial_node, :element_matcher,
      :attribute_matcher, :text_matcher, :any_text_matcher, :literal_matcher, :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each{|config| @condition_should_equal[config, @default] }
      end
    end

  end

  describe '> generating condition (w multi elements array value)' do

    before do
      @vals = %w{val-x1 val-x2 val-x3}
      @default = check_tokens("normalize-space(.)", @vals.map{|v| %|"#{v}"| })
      @condition_should_equal = lambda do |config, expected|
        @text_matcher.new(@vals, XPF::Configuration.new(config)).condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      expected = check_tokens(".", @vals.map{|v| %|"#{v}"| })
      @condition_should_equal[{:normalize_space => false}, expected]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      expected = check_tokens(translate_casing("normalize-space(.)"), @vals.map{|v| %|"#{v.upcase}"| })
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

    should "apply negation when config[:comparison] is any of: !, !=, !>, !<, !>=, !<=" do
      %w{! != !> !>= !< !<=}.each do |op|
        @condition_should_equal[{:comparison => op}, %|not(#{@default})|]
      end
    end

    should 'ignore all other specified config[:comparison]' do
      %w{= > >= < <=}.each do |op|
        @condition_should_equal[{:comparison => op}, @default]
      end
    end

    should 'honor ordering when config[:match_ordering] is true' do
      @condition_should_equal[{:match_ordering => true}, @default]
    end

    should 'not not honor ordering when config[:match_ordering] is false' do
      expected = check_tokens("normalize-space(.)", @vals.map{|v| %|"#{v}"| }, false)
      @condition_should_equal[{:match_ordering => false}, expected]
    end

    valid_config_settings_args(
      :greedy, :scope, :position, :axial_node, :element_matcher,
      :attribute_matcher, :text_matcher, :any_text_matcher, :literal_matcher, :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each{|config| @condition_should_equal[config, @default] }
      end
    end

  end

  describe '> generating condition (with value NIL_VALUE)' do

    before do
      @val = XPF::Matchers::Matchable::NIL_VALUE
      @default = %|normalize-space(.)|
      @condition_should_equal = lambda do |config, expected|
        @text_matcher.new(@val, XPF::Configuration.new(config)).condition.should.equal(expected)
      end
    end

    should "apply negation when config[:comparison] is any of: ! != !> !< !>= !<=" do
      %w{! != !> !>= !< !<=}.each do |op|
        @condition_should_equal[{:comparison => op}, %|not(#{@default})|]
      end
    end

    should 'ignore all other specified config[:comparison]' do
      %w{= > >= < <=}.each do |op|
        @condition_should_equal[{:comparison => op}, @default]
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      @condition_should_equal[{:normalize_space => false}, %|.|]
    end

    should 'include inner text when config[:include_inner_text] is true' do
      @condition_should_equal[{:include_inner_text => true}, @default]
    end

    should 'not include inner text when config[:include_inner_text] is false' do
      @condition_should_equal[{:include_inner_text => false}, %|normalize-space(text())|]
    end

    valid_config_settings_args(
      :greedy, :match_ordering, :scope, :position, :axial_node, :element_matcher,
      :attribute_matcher, :text_matcher, :any_text_matcher, :literal_matcher, :group_matcher,
      :case_sensitive
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each{|config| @condition_should_equal[config, @default] }
      end
    end

  end

end
