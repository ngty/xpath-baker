shared 'basic text matcher' do

  describe '> generating condition (with valid string value)' do

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
      expected = [translate_casing('normalize-space(.)'), %|"#{@val.downcase}"|].join('=')
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

    should 'include inner text when config[:include_inner_text] is true' do
      @condition_should_equal[{:include_inner_text => true}, @default]
    end

    should 'not include inner text when config[:include_inner_text] is false' do
      @condition_should_equal[{:include_inner_text => false}, %|normalize-space(text())="#{@val}"|]
    end

    should 'elegantly handle quoting of value with double quote (")' do
      @val = 'text-"x"'
      @condition_should_equal[{}, %|normalize-space(.)=concat("text-",'"',"x",'"',"")|]
    end

  end

  describe '> generating condition (w valid single element array value)' do

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
      expected = check_tokens(translate_casing("normalize-space(.)"), [%|"#{@val}"|])
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

  end

  describe '> generating condition (w valid multi elements array value)' do

    before do
      @vals = %w{val-x1 val-x2}
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
      expected = check_tokens(translate_casing("normalize-space(.)"), @vals.map{|v| %|"#{v}"| })
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

  end

  describe '> generating condition (with invalid value NIL_VALUE)' do

    before do
      @val = XPF::Matchers::Matchable::NIL_VALUE
      @default = %|normalize-space(.)|
      @condition_should_equal = lambda do |config, expected|
        @text_matcher.new(@val, XPF::Configuration.new(config)).condition.should.equal(expected)
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

  end

end
