shared 'basic node matcher' do

  describe '> generating condition (w valid string value)' do

    before do
      @name, @val = @name || :something, 'val1'
      @default = %|normalize-space(#{@name})="#{@val}"|
      @condition_should_equal = lambda do |config, expected|
        @node_matcher.new(@name, @val, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      @condition_should_equal[{:normalize_space => false}, %|#{@name}="#{@val}"|]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      expected = [translate_casing("normalize-space(#{@name})"), %|"#{@val.downcase}"|].join('=')
      @condition_should_equal[{:case_sensitive => false}, expected]
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
        @condition_should_equal[{:comparison => op}, expected % [@name, %|"#{@val}"|]]
      end
    end

    should 'elegantly handle quoting of value with double quote (")' do
      @val = 'val-"x"'
      @condition_should_equal[{}, %|normalize-space(#{@name})=concat("val-",'"',"x",'"',"")|]
    end

    valid_config_settings_args(
      :greedy, :match_ordering, :include_inner_text, :scope, :position, :axial_node, :element_matcher,
      :attribute_matcher, :text_matcher, :any_text_matcher, :literal_matcher, :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each{|config| @condition_should_equal[config, @default] }
      end
    end

  end

  describe '> generating condition (w valid single element array value)' do

    before do
      @name, @val = @name || :something, %w{val11}
      @default = check_tokens("normalize-space(#{@name})", [%|"#{@val}"|])
      @condition_should_equal = lambda do |config, expected|
        @node_matcher.new(@name, @val, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      expected = check_tokens("#{@name}", [%|"#{@val}"|])
      @condition_should_equal[{:normalize_space => false}, expected]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      node_expr = translate_casing("normalize-space(#{@name})")
      expected = check_tokens(translate_casing("normalize-space(#{@name})"), [%|"#{@val}"|])
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
      :greedy, :match_ordering, :include_inner_text, :scope, :position, :axial_node, :element_matcher,
      :attribute_matcher, :text_matcher, :any_text_matcher, :literal_matcher, :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each{|config| @condition_should_equal[config, @default] }
      end
    end

  end

  describe '> generating condition (w valid multi elements array value)' do

    before do
      @name, @vals = @name || :something, %w{val11 val12 val13}
      @default = check_tokens("normalize-space(#{@name})", @vals.map{|v| %|"#{v}"| })
      @condition_should_equal = lambda do |config, expected|
        @node_matcher.new(@name, @vals, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      expected = check_tokens("#{@name}", @vals.map{|v| %|"#{v}"| })
      @condition_should_equal[{:normalize_space => false}, expected]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      expected = check_tokens(translate_casing("normalize-space(#{@name})"), @vals.map{|v| %|"#{v}"| })
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
      expected = check_tokens("normalize-space(#{@name})", @vals.map{|v| %|"#{v}"| }, false)
      @condition_should_equal[{:match_ordering => false}, expected]
    end

    valid_config_settings_args(
      :greedy, :include_inner_text, :scope, :position, :axial_node, :element_matcher,
      :attribute_matcher, :text_matcher, :any_text_matcher, :literal_matcher, :group_matcher
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each{|config| @condition_should_equal[config, @default] }
      end
    end

  end

  describe '> generating condition (with invalid value NIL_VALUE)' do

    before do
      @name, @val = @name || :something, XPF::Matchers::Matchable::NIL_VALUE
      @default = %|normalize-space(#{@name})|
      @condition_should_equal = lambda do |config, expected|
        @node_matcher.new(@name, @val, XPF::Configuration.new(config)).
          condition.should.equal(expected)
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
      @condition_should_equal[{:normalize_space => false}, %|#{@name}|]
    end

    valid_config_settings_args(
      :greedy, :match_ordering, :include_inner_text, :scope, :position, :axial_node, :element_matcher,
      :attribute_matcher, :text_matcher, :any_text_matcher, :literal_matcher, :group_matcher,
      :case_sensitive
    ).each do |setting, configs|
      should "ignore config[:#{setting}]" do
        configs.each{|config| @condition_should_equal[config, @default] }
      end
    end

  end

end
