require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class << XPathFu
  attr_writer :config
  public :c, :q, :n, :t
end

describe "XPathFu::ConditionsBuilding" do

  before do
    @config_klass = Struct.new(:case_sensitive, :normalize_space, :include_inner_text)
  end

  describe '> c (converting string casing)' do

    before do
      @set_config = lambda {|flag| XPathFu.config = @config_klass.new(flag, false, false) }
    end

    should 'convert if confg.case_sensitive is false' do
      @set_config[false]
      XPathFu.c('anything').should.equal \
        %\translate(anything,"#{('A'..'Z').to_a*''}","#{('a'..'z').to_a*''}")\
    end

    should 'not convert confg.case_sensitive is true' do
      @set_config[true]
      XPathFu.c('anything').should.equal 'anything'
    end

  end

  describe '> q (quoting string)' do

    should %\escape '"' in string\ do
      XPathFu.q('"A"B').should.equal %\concat("",'"',"A",'"',"B")\
    end

    should %\apply quote (with '"') in string\ do
      XPathFu.q("'A'B").should.equal %\"'A'B"\
    end

  end

  describe '> n (normalizing space)' do

    before do
      @set_config = lambda {|flag| XPathFu.config = @config_klass.new(false, flag, false) }
    end

    should 'normalize space if config.normalize_space is true' do
      @set_config[true]
      XPathFu.n('watever').should.equal %\normalize-space(watever)\
    end

    should 'not normalize space if config.normalize_space is false' do
      @set_config[false]
      XPathFu.n('watever').should.equal %\watever\
    end

  end

  describe '> t (getting node text)' do

    before do
      @set_config = lambda {|flag| XPathFu.config = @config_klass.new(false, false, flag) }
    end

    should 'get full inner text if config.include_inner_text is true' do
      @set_config[true]
      XPathFu.t.should.equal '.'
    end

    should 'get only node text if config.include_inner_text is false' do
      @set_config[false]
      XPathFu.t.should.equal 'text()'
    end

  end

end
