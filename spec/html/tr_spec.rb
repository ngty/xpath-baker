require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'html_tr_spec_helpers')
require 'xpathfu/html'

describe "XPathFu::HTML <tr/> support" do

  before do
    XPathFu.configure do |config|
      # NOTE: Let's not assume anything, thus we are being explicite here.
      config.case_sensitive = true
      config.include_inner_text = true
      config.match_ordering = true
      config.normalize_space = true
    end
  end

  shared 'scoping for {:cells => {th1 => td1, ...}}' do
    extend HtmlTrSpecHelpers
    should "return scoped path w matching chars casing, full inner-text & with space normalized" do
      cells = {'#' => '2', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
      XPathFu.tr(*@args[cells]).should.equal \
        case_sensitive_and_normalized_space_and_full_inner_text_xpath_for(@scope || '//', cells)
    end
  end

  shared 'matching for {:cells => {th1 => td1, ...}}' do
    extend HtmlTrSpecHelpers
    should "return path that matches nodes w matching chars casing & full inner-text & space normalized" do
      cells = {'#' => '2', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
      contents_for(XPathFu.tr(*@args[cells])).should.equal ['2 John TanMale']
    end
    should "return path that does not match nodes w space already normalized" do
      cells = {'#' => '2 ', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
    should "return path that does not match nodes wo matching chars casing" do
      cells = {'#' => '2', 'full name' => 'john tan', 'gender' => 'male'}
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
    should "return path that does not match nodes wo matching full inner-text" do
      cells = {'#' => '2', 'Full ' => 'John ', 'Gender' => 'Male'}
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
  end

  {'default' => nil, 'custom valid' => '//table/'}.each do |mode, scope|

    describe "> #{mode} scoping for {:cells => {}}" do
      extend HtmlTrSpecHelpers
      should "return scoped path wo conditions" do
        XPathFu.tr(*scoped_args(scope, [{:cells => {}}])).should.equal((scope || '//')+'tr')
      end
    end

    describe "> #{mode} scoping for {:cells => {th1 => td1, ...}}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(scope, [{:cells => cells}]) }
      end
      behaves_like "scoping for {:cells => {th1 => td1, ...}}"
      behaves_like "matching for {:cells => {th1 => td1, ...}}"
    end

    describe "> #{mode} scoping for {:cells => {th1 => td1, ...}} & {:case_sensitive => true}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(@scope, [{:cells => cells}, {:case_sensitive => true}]) }
      end
      behaves_like "scoping for {:cells => {th1 => td1, ...}}"
      behaves_like "matching for {:cells => {th1 => td1, ...}}"
    end

    describe "> #{mode} scoping for {:cells => {th1 => td1, ...}} & {:include_inner_text => true}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(@scope, [{:cells => cells}, {:include_inner_text => true}]) }
      end
      behaves_like "scoping for {:cells => {th1 => td1, ...}}"
      behaves_like "matching for {:cells => {th1 => td1, ...}}"
    end

    describe "> #{mode} scoping for {:cells => {th1 => td1, ...}} & {:normalize_space => true}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(@scope, [{:cells => cells}, {:normalize_space => true}]) }
      end
      behaves_like "scoping for {:cells => {th1 => td1, ...}}"
      behaves_like "matching for {:cells => {th1 => td1, ...}}"
    end

    describe "> #{mode} scoping for {:cells => {th1 => td1, ...}} & {:case_sensitive => false}" do
      extend HtmlTrSpecHelpers
      before do
        @scope, @cells = scope, {'#' => '2', 'full name' => 'john tan', 'gender' => 'male'}
        @args = lambda { scoped_args(@scope, [{:cells => @cells}, {:case_sensitive => false}]) }
      end
      should "return scoped path ignoring chars casing" do
        XPathFu.tr(*@args[]).should.equal \
          case_insensitive_and_normalized_space_and_full_inner_text_xpath_for(@scope || '//', @cells)
      end
      should "return path that matches nodes" do
        contents_for(XPathFu.tr(*@args[])).should.equal ['2 John TanMale']
      end
    end

    describe "> #{mode} scoping for {:cells => {th1 => td1, ...}} & {:normalize_space => false}" do
      extend HtmlTrSpecHelpers
      before do
        @scope, @cells = scope, {'#' => '2 ', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
        @args = lambda { scoped_args(@scope, [{:cells => @cells}, {:normalize_space => false}]) }
      end
      should "return scoped path not normalizing space" do
        XPathFu.tr(*@args[]).should.equal \
          case_sensitive_and_unnormalized_space_and_full_inner_text_xpath_for(@scope || '//', @cells)
      end
      should "return path that matches nodes" do
        contents_for(XPathFu.tr(*@args[])).should.equal ['2 John TanMale']
      end
    end

    describe "> #{mode} scoping for {:cells => {th1 => td1, ...}} & {:include_inner_text => false}" do
      extend HtmlTrSpecHelpers
      before do
        @scope, @cells = scope, {'#' => '2', 'Full' => 'John', 'Gender' => 'Male'}
        @args = lambda { scoped_args(@scope, [{:cells => @cells}, {:include_inner_text => false}]) }
      end
      should "return scoped path that matches direct text only" do
        XPathFu.tr(*@args[]).should.equal \
          case_sensitive_and_normalized_space_and_direct_text_xpath_for(@scope || '//', @cells)
      end
      should "return path that matches nodes" do
        contents_for(XPathFu.tr(*@args[])).should.equal ['2 John TanMale']
      end
    end

  end

  describe "> custom invalid scoping for {:cells => {th1 => td1, ...}" do
    extend HtmlTrSpecHelpers
    before { @args = lambda {|cells| ['//xable/', {:cells => cells}] } }
    should "return path prefixed '//xable/'" do
      cells = {'#' => '2', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
      XPathFu.tr(*@args[cells]).should.equal \
        case_sensitive_and_normalized_space_and_full_inner_text_xpath_for('//xable/', cells)
    end
    should "return path that does not match nodes" do
      cells = {'#' => '2', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
  end

  shared 'scoping for {:cells => [td1, td2, ...]}' do
    extend HtmlTrSpecHelpers
    should "return scoped path w matching chars casing, full inner-text & with space normalized" do
      cells = ['2', 'John Tan', 'Male']
      XPathFu.tr(*@args[cells]).should.equal \
        case_sensitive_and_normalized_space_and_full_inner_text_xpath_for(@scope || '//', cells)
    end
  end

  shared 'matching for {:cells => [td1, td2, ...]}' do
    extend HtmlTrSpecHelpers
    should "return path that matches nodes w matching chars casing & full inner-text & space normalized" do
      cells = ['2', 'John Tan', 'Male']
      contents_for(XPathFu.tr(*@args[cells])).should.equal ['2 John TanMale']
    end
    should "return path that does not match nodes w ordered cells" do
      cells = ['John Tan', 'Male', '2']
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
    should "return path that does not match nodes w space already normalized" do
      cells = ['2 ', 'John Tan', 'Male']
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
    should "return path that does not match nodes wo matching chars casing" do
      cells = ['2', 'john tan', 'male']
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
    should "return path that does not match nodes wo matching full inner-text" do
      cells = ['2', 'John ', 'Male']
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
  end

  {'default' => nil, 'custom valid' => '//table/'}.each do |mode, scope|

    describe "> #{mode} scoping for {:cells => []}" do
      extend HtmlTrSpecHelpers
      should "return scoped path wo conditions" do
        XPathFu.tr(*scoped_args(scope, [{:cells => []}])).should.equal((scope || '//')+'tr')
      end
    end

    describe "> #{mode} scoping for {:cells => [td1, td2, ...]}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(scope, [{:cells => cells}]) }
      end
      behaves_like "scoping for {:cells => [td1, td2, ...]}"
      behaves_like "matching for {:cells => [td1, td2, ...]}"
    end

    describe "> #{mode} scoping for {:cells => [td1, td2, ...]} & {:match_ordering => true}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(@scope, [{:cells => cells}, {:match_ordering => true}]) }
      end
      behaves_like "scoping for {:cells => [td1, td2, ...]}"
      behaves_like "matching for {:cells => [td1, td2, ...]}"
    end

    describe "> #{mode} scoping for {:cells => [td1, td2, ...]} & {:case_sensitive => true}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(@scope, [{:cells => cells}, {:case_sensitive => true}]) }
      end
      behaves_like "scoping for {:cells => [td1, td2, ...]}"
      behaves_like "matching for {:cells => [td1, td2, ...]}"
    end

    describe "> #{mode} scoping for {:cells => [td1, td2, ...]} & {:include_inner_text => true}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(@scope, [{:cells => cells}, {:include_inner_text => true}]) }
      end
      behaves_like "scoping for {:cells => [td1, td2, ...]}"
      behaves_like "matching for {:cells => [td1, td2, ...]}"
    end

    describe "> #{mode} scoping for {:cells => [td1, td2, ...]} & {:normalize_space => true}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(@scope, [{:cells => cells}, {:normalize_space => true}]) }
      end
      behaves_like "scoping for {:cells => [td1, td2, ...]}"
      behaves_like "matching for {:cells => [td1, td2, ...]}"
    end

    describe "> #{mode} scoping for {:cells => [td1, td2, ...]} & {:match_ordering => false}" do
      extend HtmlTrSpecHelpers
      before do
        @scope, @cells = scope, ['John Tan', 'Male', '2']
        @args = lambda { scoped_args(@scope, [{:cells => @cells}, {:match_ordering => false}]) }
      end
      should "return scoped path ignoring cell ordering" do
        XPathFu.tr(*@args[]).should.equal \
          '%str%s' % [@scope || '//', @cells.map {|val| %\[./td[normalize-space(.)="#{val}"]]\ }.join('')]
      end
      should "return path that matches nodes" do
        contents_for(XPathFu.tr(*@args[])).should.equal ['2 John TanMale']
      end
    end

    describe "> #{mode} scoping for {:cells => [td1, td2, ...]} & {:case_sensitive => false}" do
      extend HtmlTrSpecHelpers
      before do
        @scope, @cells = scope, ['2', 'john tan', 'male']
        @args = lambda { scoped_args(@scope, [{:cells => @cells}, {:case_sensitive => false}]) }
      end
      should "return scoped path ignoring chars casing" do
        XPathFu.tr(*@args[]).should.equal \
          case_insensitive_and_normalized_space_and_full_inner_text_xpath_for(@scope || '//', @cells)
      end
      should "return path that matches nodes" do
        contents_for(XPathFu.tr(*@args[])).should.equal ['2 John TanMale']
      end
    end

    describe "> #{mode} scoping for {:cells => [td1, td2, ...]} & {:normalize_space => false}" do
      extend HtmlTrSpecHelpers
      before do
        @scope, @cells = scope, ['2 ', 'John Tan', 'Male']
        @args = lambda { scoped_args(@scope, [{:cells => @cells}, {:normalize_space => false}]) }
      end
      should "return scoped path not normalizing space" do
        XPathFu.tr(*@args[]).should.equal \
          case_sensitive_and_unnormalized_space_and_full_inner_text_xpath_for(@scope || '//', @cells)
      end
      should "return path that matches nodes" do
        contents_for(XPathFu.tr(*@args[])).should.equal ['2 John TanMale']
      end
    end

    describe "> #{mode} scoping for {:cells => [td1, td2, ...]} & {:include_inner_text => false}" do
      extend HtmlTrSpecHelpers
      before do
        @scope, @cells = scope, ['2', 'John', 'Male']
        @args = lambda { scoped_args(@scope, [{:cells => @cells}, {:include_inner_text => false}]) }
      end
      should "return scoped path that matches direct text only" do
        XPathFu.tr(*@args[]).should.equal \
          case_sensitive_and_normalized_space_and_direct_text_xpath_for(@scope || '//', @cells)
      end
      should "return path that matches nodes" do
        contents_for(XPathFu.tr(*@args[])).should.equal ['2 John TanMale']
      end
    end

  end

  describe "> custom invalid scoping for {:cells => [td1, td2, ...]}" do
    extend HtmlTrSpecHelpers
    before { @args = lambda {|cells| ['//xable/', {:cells => cells}] } }
    should "return path prefixed '//xable/'" do
      cells = ['2', 'John Tan', 'Male']
      XPathFu.tr(*@args[cells]).should.equal \
        case_sensitive_and_normalized_space_and_full_inner_text_xpath_for('//xable/', cells)
    end
    should "return path that does not match nodes" do
      cells = ['2', 'John Tan', 'Male']
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
  end

  describe '> {:cells => ...} match attr' do
    should 'not raise XPathFu::InvalidArgumentError for hash value' do
      lambda { XPathFu.tr(:cells => {}) }.should.not.raise(XPathFu::InvalidArgumentError)
    end
    should 'not raise XPathFu::InvalidArgumentError for array value' do
      lambda { XPathFu.tr(:cells => []) }.should.not.raise(XPathFu::InvalidArgumentError)
    end
    should 'raise XPathFu::InvalidArgumentError for other value' do
      lambda { XPathFu.tr(:cells => '') }.
        should.raise(XPathFu::InvalidArgumentError).
        message.should.equal('Match attribute :cells must be a Hash or Array.')
    end
  end

  shared 'scoping for {:attr1 => val1, ...}' do
    extend HtmlTrSpecHelpers
    should "return scoped path w attrs value matching chars casing & with space normalized" do
      attrs = {:id => 'Conky', :class => 'red'}
      XPathFu.tr(*@args[attrs]).should.equal \
        case_sensitive_and_normalized_space_xpath_for(@scope || '//', attrs)
    end
  end

  shared 'matching for {:attr1 => val1, ...}' do
    extend HtmlTrSpecHelpers
    should "return path that matches nodes w attrs value matching chars casing & space normalized" do
      attrs = {:id => 'Conky', :class => 'red'}
      contents_for(XPathFu.tr(*@args[attrs])).should.equal ['2 John TanMale']
    end
    should "return path that does not match nodes w space already normalized" do
      attrs = {:id => 'Conky ', :class => 'red'}
      contents_for(XPathFu.tr(*@args[attrs])).should.be.empty
    end
    should "return path that does not match nodes wo matching chars casing" do
      attrs = {:id => 'conky', :class => 'red'}
      contents_for(XPathFu.tr(*@args[attrs])).should.be.empty
    end
  end

  {'default' => nil, 'custom valid' => '//table/'}.each do |mode, scope|

    describe "> #{mode} scoping for {:attr1 => val1, ... }" do
      before do
        @scope = scope
        @args = lambda {|attrs| scoped_args(@scope, [attrs]) }
      end
      behaves_like "scoping for {:attr1 => val1, ...}"
      behaves_like "matching for {:attr1 => val1, ...}"
    end

    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:case_sensitive => true}" do
      before do
        @scope = scope
        @args = lambda {|attrs| scoped_args(@scope, [attrs, {:case_sensitive => true}]) }
      end
      behaves_like "scoping for {:attr1 => val1, ...}"
      behaves_like "matching for {:attr1 => val1, ...}"
    end

    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:normalize_space => true}" do
      before do
        @scope = scope
        @args = lambda {|attrs| scoped_args(@scope, [attrs, {:normalize_space => true}]) }
      end
      behaves_like "scoping for {:attr1 => val1, ...}"
      behaves_like "matching for {:attr1 => val1, ...}"
    end

    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:case_sensitive => false}" do
      extend HtmlTrSpecHelpers
      before do
        @scope, @attrs = scope, {:id => 'conky', :class => 'red'}
        @args = lambda { scoped_args(@scope, [@attrs, {:case_sensitive => false}]) }
      end
      should "return scoped path ignoring chars casing" do
        XPathFu.tr(*@args[]).should.equal \
          case_insensitive_and_normalized_space_xpath_for(@scope || '//', @attrs)
      end
      should "return path that matches nodes" do
        contents_for(XPathFu.tr(*@args[])).should.equal ['2 John TanMale']
      end
    end

    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:normalize_space => false}" do
      extend HtmlTrSpecHelpers
      before do
        @scope, @attrs = scope, {:id => 'Conky ', :class => 'red'}
        @args = lambda { scoped_args(@scope, [@attrs, {:normalize_space => false}]) }
      end
      should "return scoped path not normalizing space" do
        XPathFu.tr(*@args[]).should.equal \
          case_sensitive_and_unnormalized_space_xpath_for(@scope || '//', @attrs)
      end
      should "return path that matches nodes" do
        contents_for(XPathFu.tr(*@args[])).should.equal ['2 John TanMale']
      end
    end

  end

  describe "> custom invalid scoping for {:attr1 => val1, ...}" do
    extend HtmlTrSpecHelpers
    before { @args = lambda {|attrs| ['//xable/', attrs] } }
    should "return path prefixed '//xable/'" do
      attrs = {:id => 'Conky', :class => 'red'}
      XPathFu.tr(*@args[attrs]).should.equal \
        case_sensitive_and_normalized_space_xpath_for('//xable/', attrs)
    end
    should "return path that does not match nodes" do
      attrs = {:id => 'Conky', :class => 'red'}
      contents_for(XPathFu.tr(*@args[attrs])).should.be.empty
    end
  end

  describe '> no match attrs specified' do
    should "return '//tr' with no scoped specified" do
      XPathFu.tr.should.equal '//tr'
    end
    should "return '//xable/tr' with scope '//xable/' specified" do
      XPathFu.tr('//xable/').should.equal '//xable/tr'
    end
  end

end

