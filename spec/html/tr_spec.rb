require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'xpathfu/html'

module HtmlTrSpecHelpers

  def contents_for(path)
    Nokogiri::HTML(%\
      <html>
        <body>
          <table>
            <tr><th><span>#</span></th><th><span>Full <br/>Name</span></th><th>Gender</th></tr>
            <tr><td> 1</td><td>Jane <br/>Lee</td><td>Female</td></tr>
            <tr><td>2 </td><td>John <br/>Tan</td><td>Male</td></tr>
          </table>
        </body>
      </html>
    \).xpath(path).map(&:text)
  end

  def case_sensitive_and_normalized_space_and_full_inner_text_xpath_for(scope, cells)
    "#{scope}tr[%s]" % cells.map do |field, val|
      header = %\./ancestor::table[1]//th[normalize-space(.)="#{field}"][1]\
      %\.//td[count(#{header}/preceding-sibling::th)+1][#{header}][normalize-space(.)="#{val}"]\
    end.join('][')
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

  shared 'default scoping for {:cells => {header1 => col1, ...}}' do
    extend HtmlTrSpecHelpers
    should "return path scoped '//' w matching char casing, full inner-text & with space normalized" do
      cells = {'#' => '2', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
      XPathFu.tr(*@args[cells]).should.equal \
        case_sensitive_and_normalized_space_and_full_inner_text_xpath_for('//', cells)
    end
  end

  shared 'default matching for {:cells => {header1 => col1, ...}}' do
    extend HtmlTrSpecHelpers
    should "return path that matches nodes w matching char casing & full inner-text & space normalized" do
      cells = {'#' => '2', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
      contents_for(XPathFu.tr(*@args[cells])).should.equal ['2 John TanMale']
    end
    should "return path that does not match nodes w space already normalized" do
      cells = {'#' => '2 ', 'Full Name' => 'john tan', 'Gender' => 'male'}
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
    should "return path that does not match nodes wo matching char casing" do
      cells = {'#' => '2', 'Full Name' => 'john tan', 'Gender' => 'male'}
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
    should "return path that does not match nodes wo matching full inner-text" do
      cells = {'#' => '2', 'Full ' => 'John ', 'Gender' => 'Male'}
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
  end

  describe '> default scope for {:cells => {header1 => col1, ...}}' do
    before { @args = lambda {|cells| [{:cells => cells}] } }
    behaves_like 'default scoping for {:cells => {header1 => col1, ...}}'
    behaves_like 'default matching for {:cells => {header1 => col1, ...}}'
  end

  describe '> default scope for {:cells => {header1 => col1, ...}}, {:case_sensitive => true}' do
    before { @args = lambda {|cells| [{:cells => cells}, {:case_sensitive => true}] } }
    behaves_like 'default scoping for {:cells => {header1 => col1, ...}}'
    behaves_like 'default matching for {:cells => {header1 => col1, ...}}'
  end

  describe '> default scope for {:cells => {header1 => col1, ...}}, {:include_inner_text => true}' do
    before { @args = lambda {|cells| [{:cells => cells}, {:include_inner_text => true}] } }
    behaves_like 'default scoping for {:cells => {header1 => col1, ...}}'
    behaves_like 'default matching for {:cells => {header1 => col1, ...}}'
  end

  describe '> default scope for {:cells => {header1 => col1, ...}}, {:normalize_space => true}' do
    before { @args = lambda {|cells| [{:cells => cells}, {:normalize_space => true}] } }
    behaves_like 'default scoping for {:cells => {header1 => col1, ...}}'
    behaves_like 'default matching for {:cells => {header1 => col1, ...}}'
  end

  shared "custom valid scoping {:cells => {header1 => col1, ...}}" do
    extend HtmlTrSpecHelpers
    should "return path prefixed '//table/' w matching char casing, full inner-text & with space normalized" do
      cells = {'#' => '2', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
      XPathFu.tr(*@args[cells]).should.equal \
        case_sensitive_and_normalized_space_and_full_inner_text_xpath_for('//table/', cells)
    end
  end

  describe "> custom valid scoping for {:cells => {header1 => col1, ...}" do
    before { @args = lambda {|cells| ['//table/', {:cells => cells}] } }
    behaves_like "custom valid scoping {:cells => {header1 => col1, ...}}"
    behaves_like 'default matching for {:cells => {header1 => col1, ...}}'
  end

  describe '> custom valid scoping for {:cells => {header1 => col1, ...}}, {:case_sensitive => true}' do
    before { @args = lambda {|cells| ['//table/', {:cells => cells}, {:case_sensitive => true}] } }
    behaves_like 'custom valid scoping {:cells => {header1 => col1, ...}}'
    behaves_like 'default matching for {:cells => {header1 => col1, ...}}'
  end

  describe '> custom valid scoping for {:cells => {header1 => col1, ...}}, {:include_inner_text => true}' do
    before { @args = lambda {|cells| ['//table/', {:cells => cells}, {:include_inner_text => true}] } }
    behaves_like 'custom valid scoping {:cells => {header1 => col1, ...}}'
    behaves_like 'default matching for {:cells => {header1 => col1, ...}}'
  end

  describe '> custom valid scoping for {:cells => {header1 => col1, ...}}, {:normalize_space => true}' do
    before { @args = lambda {|cells| ['//table/', {:cells => cells}, {:normalize_space => true}] } }
    behaves_like 'custom valid scoping {:cells => {header1 => col1, ...}}'
    behaves_like 'default matching for {:cells => {header1 => col1, ...}}'
  end

  describe "> custom invalid scoping for {:cells => {header1 => col1, ...}" do
    extend HtmlTrSpecHelpers
    before { @args = lambda {|cells| ['/table/', {:cells => cells}] } }
    should "return path prefixed '/table/' w matching char casing, full inner-text & with space normalized" do
      cells = {'#' => '2', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
      XPathFu.tr(*@args[cells]).should.equal \
        case_sensitive_and_normalized_space_and_full_inner_text_xpath_for('/table/', cells)
    end
    should "return path that does not match nodes w matching char casing & full inner-text & space normalized" do
      cells = {'#' => '2', 'Full Name' => 'John Tan', 'Gender' => 'Male'}
      contents_for(XPathFu.tr(*@args[cells])).should.be.empty
    end
  end

end

