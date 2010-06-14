shared 'basic attribute matcher' do

  describe '> generating condition (w valid string value)' do

    before do
      @name, @val = @name || 'attr-x', 'val-x'
      @default = %|normalize-space(@#{@name})="#{@val}"|
      @condition_should_equal = lambda do |config, expected|
        @attr_matcher.new(@name, @val, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      @condition_should_equal[{:normalize_space => false}, %|@#{@name}="#{@val}"|]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      expected = [translate_casing("normalize-space(@#{@name})"), %|"#{@val.downcase}"|].join('=')
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

    should 'elegantly handle quoting of value with double quote (")' do
      @val = 'val-"x"'
      @condition_should_equal[{}, %|normalize-space(@#{@name})=concat("val-",'"',"x",'"',"")|]
    end

  end

  describe '> generating condition (w valid single element array value)' do

    before do
      @name, @val = @name || 'attr-x', %w{val-x1}
      @default = check_tokens("normalize-space(@#{@name})", %|"#{@val}"|)
      @condition_should_equal = lambda do |config, expected|
        @attr_matcher.new(@name, @val, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      expected = check_tokens("@#{@name}", %|"#{@val}"|)
      @condition_should_equal[{:normalize_space => false}, expected]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      attr_expr = translate_casing("normalize-space(@#{@name})")
      expected = check_tokens(translate_casing("normalize-space(@#{@name})"), %|"#{@val}"|)
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

  end

  describe '> generating condition (w valid multi elements array value)' do

    before do
      @name, @vals = @name || 'attr-x', %w{val-x1 val-x2}
      @default = check_tokens("normalize-space(@#{@name})", @vals.map{|v| %|"#{v}"| })
      @condition_should_equal = lambda do |config, expected|
        @attr_matcher.new(@name, @vals, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      expected = check_tokens("@#{@name}", @vals.map{|v| %|"#{v}"| })
      @condition_should_equal[{:normalize_space => false}, expected]
    end

    should 'be case-sensitive when config[:case_sensitive] is true' do
      @condition_should_equal[{:case_sensitive => true}, @default]
    end

    should 'not be case-sensitive when config[:case_sensitive] is false' do
      expected = check_tokens(translate_casing("normalize-space(@#{@name})"), @vals.map{|v| %|"#{v}"| })
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

  end

  describe '> generating condition (with invalid value NIL_VALUE)' do

    before do
      @name, @val = @name || 'attr-x', XPF::Matchers::Matchable::NIL_VALUE
      @default = %|normalize-space(@#{@name})|
      @condition_should_equal = lambda do |config, expected|
        XPF::Matchers::Attribute.new(@name, @val, XPF::Configuration.new(config)).
          condition.should.equal(expected)
      end
    end

    should 'have space normalized when config[:normalize_space] is true' do
      @condition_should_equal[{:normalize_space => true}, @default]
    end

    should 'not have space normalized when config[:normalize_space] is false' do
      @condition_should_equal[{:normalize_space => false}, %|@#{@name}|]
    end

  end

end
