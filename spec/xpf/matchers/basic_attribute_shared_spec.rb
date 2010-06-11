shared 'basic attribute matcher' do

  describe '> generating condition (with valid value)' do

    before do
      uc, lc = [('A'..'Z'), ('a'..'z')].map {|r| r.to_a.join('') }
      @translate = lambda {|s| %|translate(#{s},"#{uc}","#{lc}")| }
      @name, @val = 'attr-x', 'val-x'
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
      expected = ["normalize-space(@#{@name})", %|"#{@val}"|].map{|s| @translate[s] }.join('=')
      @condition_should_equal[{:case_sensitive => false}, expected]
    end

    should 'elegantly handle quoting of value with double quote (")' do
      @val = 'val-"x"'
      @condition_should_equal[{}, %|normalize-space(@#{@name})=concat("val-",'"',"x",'"',"")|]
    end

  end

  describe '> generating condition (with invalid value NIL_VALUE)' do

    before do
      @name, @val = 'attr-x', XPF::Matchers::Matchable::NIL_VALUE
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
