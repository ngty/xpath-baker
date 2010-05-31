require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'xpathfu/html'

module HtmlTrSpecHelpers

  def contents_for(path)
    (@hdoc = Nokogiri::HTML(%\
      <html>
        <body>
          <table>
            <tr><th>#</th><th>Full <br/>Name</th><th>Gender</th></tr>
            <tr><td> 1</td><td>Jane <br/>Lee</td><td>Female</td></tr>
            <tr><td>2 </td><td>John <br/>Tan</td><td>Male</td></tr>
            <tr><td> 3 </td><td>Jim <br/>Ma</td><td>Male</td></tr>
          </table>
        </body>
      </html>
    \)).xpath(path).map(&:text)
  end

  def case_sensitive_and_normalized_space_and_full_inner_text_xpath_for(scope, cells)
    "#{scope}tr[%s]" % cells.map do |field, val|
      th = %\./ancestor::table[1]//th[normalize-space(.)="#{field}"][1]\
      %\.//td[count(#{th}/preceding-sibling::th)+1][#{th}][normalize-space(.)="#{val}"]\
    end.join('][')
  end

  def case_sensitive_and_unnormalized_space_and_full_inner_text_xpath_for(scope, cells)
    "#{scope}tr[%s]" % cells.map do |field, val|
      th = %\./ancestor::table[1]//th[.="#{field}"][1]\
      %\.//td[count(#{th}/preceding-sibling::th)+1][#{th}][.="#{val}"]\
    end.join('][')
  end

  def case_sensitive_and_normalized_space_and_direct_text_xpath_for(scope, cells)
    "#{scope}tr[%s]" % cells.map do |field, val|
      th = %\./ancestor::table[1]//th[normalize-space(text())="#{field}"][1]\
      %\.//td[count(#{th}/preceding-sibling::th)+1][#{th}][normalize-space(text())="#{val}"]\
    end.join('][')
  end

  def case_insensitive_and_normalized_space_and_full_inner_text_xpath_for(scope, cells)
    upper_chars, lower_chars = ['A'..'Z', 'a'..'z'].map {|r| r.to_a.join('') }
    translate = lambda {|s| %\translate(#{s},"#{upper_chars}","#{lower_chars}")\ }
    "#{scope}tr[%s]" % cells.map do |field, val|
      th = %\./ancestor::table[1]//th[#{translate['normalize-space(.)']}=#{translate[%\"#{field}"\]}][1]\
      %\.//td[count(#{th}/preceding-sibling::th)+1][#{th}]\ +
        %\[#{translate['normalize-space(.)']}=#{translate[%\"#{val}"\]}]\
    end.join('][')
  end

  def scoped_args(scope, args)
    scope ? args.unshift(scope) : args
  end

end

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

  shared 'scoping for {:cells => {header1 => col1, ...}}' do
    extend HtmlTrSpecHelpers
    should "return scoped path w matching chars casing, full inner-text & with space normalized" do
      cells = {'#' => '2', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
      XPathFu.tr(*@args[cells]).should.equal \
        case_sensitive_and_normalized_space_and_full_inner_text_xpath_for(@scope || '//', cells)
    end
  end

  shared 'matching for {:cells => {header1 => col1, ...}}' do
    extend HtmlTrSpecHelpers
    should "return path that matches nodes w matching chars casing & full inner-text & space normalized" do
      cells = {'#' => '2', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
      contents_for(XPathFu.tr(*@args[cells])).should.equal ['2 John TanMale']
    end
    should "return path that does not match nodes w space already normalized" do
      cells = {'#' => '2 ', 'Full Name' => 'john tan', 'Gender' => 'male'}
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
    should "return path that does not match nodes wo matching chars casing" do
      cells = {'#' => '2', 'Full Name' => 'john tan', 'Gender' => 'male'}
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
    should "return path that does not match nodes wo matching full inner-text" do
      cells = {'#' => '2', 'Full ' => 'John ', 'Gender' => 'Male'}
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
  end

  {'default' => nil, 'custom valid' => '//table/'}.each do |mode, scope|

    describe "> #{mode} scoping for {:cells => {header1 => col1, ...}}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(scope, [{:cells => cells}]) }
      end
      behaves_like "scoping for {:cells => {header1 => col1, ...}}"
      behaves_like "matching for {:cells => {header1 => col1, ...}}"
    end

    describe "> #{mode} scoping for {:cells => {header1 => col1, ...}} & {:case_sensitive => true}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(@scope, [{:cells => cells}, {:case_sensitive => true}]) }
      end
      behaves_like "scoping for {:cells => {header1 => col1, ...}}"
      behaves_like "matching for {:cells => {header1 => col1, ...}}"
    end

    describe "> #{mode} scoping for {:cells => {header1 => col1, ...}} & {:include_inner_text => true}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(@scope, [{:cells => cells}, {:include_inner_text => true}]) }
      end
      behaves_like "scoping for {:cells => {header1 => col1, ...}}"
      behaves_like "matching for {:cells => {header1 => col1, ...}}"
    end

    describe "> #{mode} scoping for {:cells => {header1 => col1, ...}} & {:normalize_space => true}" do
      before do
        @scope = scope
        @args = lambda {|cells| scoped_args(@scope, [{:cells => cells}, {:normalize_space => true}]) }
      end
      behaves_like "scoping for {:cells => {header1 => col1, ...}}"
      behaves_like "matching for {:cells => {header1 => col1, ...}}"
    end

    describe "> #{mode} scoping for {:cells => {header1 => col1, ...}} & {:case_sensitive => false}" do
      extend HtmlTrSpecHelpers
      before do
        @scope, @cells = scope, {'#' => '2', 'full name' => 'john tan', 'gender' => 'male'}
        @args = lambda { scoped_args(@scope, [{:cells => @cells}, {:case_sensitive => false}]) }
      end
      should "return scoped path w matching chars (ignore casing), full inner-text & with space normalized" do
        XPathFu.tr(*@args[]).should.equal \
          case_insensitive_and_normalized_space_and_full_inner_text_xpath_for(@scope || '//', @cells)
      end
      should "return path that matches nodes w matching chars (ignore casing)" do
        contents_for(XPathFu.tr(*@args[])).should.equal ['2 John TanMale']
      end
    end

    describe "> #{mode} scoping for {:cells => {header1 => col1, ...}} & {:normalize_space => false}" do
      extend HtmlTrSpecHelpers
      before do
        @scope, @cells = scope, {'#' => '2 ', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
        @args = lambda { scoped_args(@scope, [{:cells => @cells}, {:normalize_space => false}]) }
      end
      should "return scoped path w matching chars casing, full inner-text & with space unnormalized" do
        XPathFu.tr(*@args[]).should.equal \
          case_sensitive_and_unnormalized_space_and_full_inner_text_xpath_for(@scope || '//', @cells)
      end
      should "return path that matches nodes w space unnormalized" do
        contents_for(XPathFu.tr(*@args[])).should.equal ['2 John TanMale']
      end
    end

    describe "> #{mode} scoping for {:cells => {header1 => col1, ...}} & {:include_inner_text => false}" do
      extend HtmlTrSpecHelpers
      before do
        @scope, @cells = scope, {'#' => '2', 'Full' => 'John', 'Gender' => 'Male'}
        @args = lambda { scoped_args(@scope, [{:cells => @cells}, {:include_inner_text => false}]) }
      end
      should "return scoped path w matching chars casing, direct text only & with space normalized" do
        XPathFu.tr(*@args[]).should.equal \
          case_sensitive_and_normalized_space_and_direct_text_xpath_for(@scope || '//', @cells)
      end
      should "return path that matches nodes w matching direct text only" do
        contents_for(XPathFu.tr(*@args[])).should.equal ['2 John TanMale']
      end
    end

  end

  describe "> custom invalid scoping for {:cells => {header1 => col1, ...}" do
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

end

