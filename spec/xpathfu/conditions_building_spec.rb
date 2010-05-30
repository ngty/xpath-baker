require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class << XPathFu
  attr_writer :config
  public :t, :q
end

describe "XPathFu::ConditionsBuilding" do

  describe '> translating string' do

    before do
      @config_klass = Struct.new(:case_sensitive)
    end

    should 'translate if confg.case_sensitive is false' do
      XPathFu.config = @config_klass.new(false)
      XPathFu.t('anything').should.equal \
        %\translate("#{('A'..'Z').to_a*''}","#{('a'..'z').to_a*''}",anything)\
    end

    should 'not translate confg.case_sensitive is true' do
      XPathFu.config = @config_klass.new(true)
      XPathFu.t('anything').should.equal 'anything'
    end

  end

  describe '> quoting string' do

    should %\escape '"' in string\ do
      XPathFu.q('"A"B').should.equal %\concat("",'"',"A",'"',"B")\
    end

    should %\apply quote (with '"') in string\ do
      XPathFu.q("'A'B").should.equal %\"'A'B"\
    end

  end

end
