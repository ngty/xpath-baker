require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe "XPF::Matchers::Text" do

  describe '> generating condition' do

    before do
      uc, lc = [('A'..'Z'), ('a'..'z')].map {|r| r.to_a.join('') }
      @translate = lambda {|s| %|translate(#{s},"#{uc}","#{lc}")| }
      @val = 'text-x'
      @default = %|normalize-space(.)="#{@val}"|
      @condition_should_equal = lambda do |config, expected|
        XPF::Matchers::Text.new(@val, XPF::Configuration.new(config)).
          condition.should.equal(expected)
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
      expected = ['normalize-space(.)', %|"#{@val}"|].map{|s| @translate[s] }.join('=')
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

end
