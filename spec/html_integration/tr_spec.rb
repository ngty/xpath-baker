require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'xpf/html'

describe "XPF::HTML <tr/> support" do

  tr_axed_path = lambda do |text_comparison, tds, axial_node, match_ordering|
    test = lambda do |val|
      val.is_a?(Array) ? check_tokens(text_comparison, val.map{|v| %|"#{v}"| }, match_ordering) :
        %|#{text_comparison}="#{val}"|
    end
    test_value = lambda{|val| (axial_node == 'self::*' ? '%s' : "./#{axial_node}[%s]") % test[val] }
    test_field = lambda{|val| test[val] }
    '//tr[%s]' % (
      case tds
      when nil
        './td[%s]' % (axial_node == 'self::*' ? '%s' : "./#{axial_node}[%s]") % text_comparison
      when Hash
        tds.map do |field, val|
          th = %|./ancestor::table[1]//th[#{test_field[field]}][1]|
          %\./td[count(#{th}/preceding-sibling::th)+1][#{th}][#{test_value[val]}]\
        end.join('][')
      else
        !match_ordering ? (tds.map {|val| './td[%s]' % test_value[val] }.join('][')) :
          ('./td[%s]' % tds.map {|val| test_value[val] }.join(']/following-sibling::td['))
      end
    )
  end

  tr_path = lambda do |text_comparison, tds, match_ordering|
    tr_axed_path[text_comparison, tds, 'self::*', match_ordering]
  end

  downcase = lambda do |tds|
    tds.is_a?(Hash) ?
      tds.inject({}){|memo, (field,val)| memo.merge(field.downcase => val.downcase) } :
      tds.map{|val| val.downcase }
  end

  ids = lambda do |path|
    Nokogiri::HTML(%\
      <html>
        <body>
          <table>
            <tr id="e1"><th>#</th> <th>Full <span> Name</span></th>
            <tr id="e2"><td> 1</td><td>Jane <span> Lee </span></td>
            <tr id="e3"><td>2 </td><td>John <span> Tan </span></td>
            <tr id="e4"><td>  </td><td>     <span>     </span></td>
            <tr id="e5"><td>  </td><td>Pett <span>     </span></td>
            <tr id="e6"><td>  </td><td>     <span> Fan </span></td>
          </table>
        </body>
      </html>
    \).xpath(path).map{|node| node.attribute('id').to_s }
  end

  {
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # {:normalize_space => ... }
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # >> {:tds => {...}}
    [{:tds => (tds = {'#' => '2', 'Full Name' => 'John Tan'})}, {:normalize_space => true}] =>
      [tr_path['normalize-space(.)', tds, nil], %w{e3}],
    [{:tds => (tds = {'#' => '2 ', 'Full  Name' => 'John  Tan '})}, {:normalize_space => true}] =>
      [tr_path['normalize-space(.)', tds, nil], %w{}],
    [{:tds => (tds = {'#' => '2 ', 'Full  Name' => 'John  Tan '})}, {:normalize_space => false}] =>
      [tr_path['.', tds, nil], %w{e3}],
    [{:tds => (tds = {'#' => '2', 'Full Name' => 'John Tan'})}, {:normalize_space => false}] =>
      [tr_path['.', tds, nil], %w{}],
    # >> {:tds => [...]}
    [{:tds => (tds = ['2', 'John Tan'])}, {:normalize_space => true}] =>
      [tr_path['normalize-space(.)', tds, true], %w{e3}],
    [{:tds => (tds = ['2 ', 'John  Tan '])}, {:normalize_space => true}] =>
      [tr_path['normalize-space(.)', tds, true], %w{}],
    [{:tds => (tds = ['2 ', 'John  Tan '])}, {:normalize_space => false}] =>
      [tr_path['.', tds, true], %w{e3}],
    [{:tds => (tds = ['2', 'John Tan'])}, {:normalize_space => false}] =>
      [tr_path['.', tds, true], %w{}],
    # >> [:tds]
    [[:tds], {:normalize_space => true}] =>
      [tr_path['normalize-space(.)', nil, nil], %w{e2 e3 e5 e6}],
    [[:tds], {:normalize_space => false}] =>
      [tr_path['.', nil, nil], %w{e2 e3 e4 e5 e6}],
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # {:include_inner_text => ... }
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # >> {:tds => {...}}
    [{:tds => (tds = {'#' => '2', 'Full Name' => 'John Tan'})}, {:include_inner_text => true}] =>
      [tr_path['normalize-space(.)', tds, nil], %w{e3}],
    [{:tds => (tds = {'#' => '2', 'Full' => 'John'})}, {:include_inner_text => true}] =>
      [tr_path['normalize-space(.)', tds, nil], %w{}],
    [{:tds => (tds = {'#' => '2', 'Full Name' => 'John Tan'})}, {:include_inner_text => false}] =>
      [tr_path['normalize-space(text())', tds, nil], %w{}],
    [{:tds => (tds = {'#' => '2', 'Full' => 'John'})}, {:include_inner_text => false}] =>
      [tr_path['normalize-space(text())', tds, nil], %w{e3}],
    # >> {:tds => [...]}
    [{:tds => (tds = ['2', 'John Tan'])}, {:include_inner_text => true}] =>
      [tr_path['normalize-space(.)', tds, true], %w{e3}],
    [{:tds => (tds = ['2', 'John'])}, {:include_inner_text => true}] =>
      [tr_path['normalize-space(.)', tds, true], %w{}],
    [{:tds => (tds = ['2', 'John Tan'])}, {:include_inner_text => false}] =>
      [tr_path['normalize-space(text())', tds, true], %w{}],
    [{:tds => (tds = ['2', 'John'])}, {:include_inner_text => false}] =>
      [tr_path['normalize-space(text())', tds, true], %w{e3}],
    # >> [:tds]
    [[:tds], {:include_inner_text => true}] =>
      [tr_path['normalize-space(.)', nil, nil], %w{e2 e3 e5 e6}],
    [[:tds], {:include_inner_text => false}] =>
      [tr_path['normalize-space(text())', nil, nil], %w{e2 e3 e5}],
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # {:case_sensitive => ... }
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # >> {:tds => {...}}
    [{:tds => (tds = {'#' => '2', 'Full Name' => 'John Tan'})}, {:case_sensitive => true}] =>
      [tr_path['normalize-space(.)', tds, nil], %w{e3}],
    [{:tds => (tds = {'#' => '2', 'full name' => 'john tan'})}, {:case_sensitive => true}] =>
      [tr_path['normalize-space(.)', tds, nil], %w{}],
    [{:tds => (tds = {'#' => '2', 'full name' => 'john tan'})}, {:case_sensitive => false}] =>
      [tr_path[translate_casing('normalize-space(.)'), downcase[tds], nil], %w{e3}],
    [{:tds => (tds = {'#' => '2', 'Full Name' => 'John Tan'})}, {:case_sensitive => false}] =>
      [tr_path[translate_casing('normalize-space(.)'), downcase[tds], nil], %w{e3}],
    # >> {:tds => [...]}
    [{:tds => (tds = ['2', 'John Tan'])}, {:case_sensitive => true}] =>
      [tr_path['normalize-space(.)', tds, true], %w{e3}],
    [{:tds => (tds = ['2', 'john tan'])}, {:case_sensitive => true}] =>
      [tr_path['normalize-space(.)', tds, true], %w{}],
    [{:tds => (tds = ['2', 'john tan'])}, {:case_sensitive => false}] =>
      [tr_path[translate_casing('normalize-space(.)'), downcase[tds], true], %w{e3}],
    [{:tds => (tds = ['2', 'John Tan'])}, {:case_sensitive => false}] =>
      [tr_path[translate_casing('normalize-space(.)'), downcase[tds], true], %w{e3}],
    # >> [:tds] (NA)
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # {:match_ordering => ... }
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # >> {:tds => {...}}
    [{:tds => (tds = {'#' => '2', 'Full Name' => %w{John Tan}})}, {:match_ordering => true}] =>
      [tr_path['normalize-space(.)', tds, true], %w{e3}],
    [{:tds => (tds = {'#' => '2', %w{Name Full} => %w{Tan John}})}, {:match_ordering => true}] =>
      [tr_path['normalize-space(.)', tds, true], %w{}],
    [{:tds => (tds = {'#' => '2', 'Full Name' => %w{John Tan}})}, {:match_ordering => false}] =>
      [tr_path['normalize-space(.)', tds, false], %w{e3}],
    [{:tds => (tds = {'#' => '2', %w{Name Full} => %w{Tan John}})}, {:match_ordering => false}] =>
      [tr_path['normalize-space(.)', tds, false], %w{e3}],
    # >> {:tds => [...]}
    [{:tds => (tds = ['2', %w{John Tan}])}, {:match_ordering => true}] =>
      [tr_path['normalize-space(.)', tds, true], %w{e3}],
    [{:tds => (tds = [%w{John Tan}, '2'])}, {:match_ordering => true}] =>
      [tr_path['normalize-space(.)', tds, true], %w{}],
    [{:tds => (tds = ['2', %w{Tan John}])}, {:match_ordering => false}] =>
      [tr_path['normalize-space(.)', tds, false], %w{e3}],
    [{:tds => (tds = [%w{Tan John}, '2'])}, {:match_ordering => false}] =>
      [tr_path['normalize-space(.)', tds, false], %w{e3}],
    # >> [:tds] (NA)
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # {:axial_node => ... }
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # >> {:tds => {...}}
    [{:tds => (tds = {'Full Name' => 'Tan'})}, {:axial_node => 'self::*'}] =>
      [tr_axed_path['normalize-space(.)', tds, 'self::*', true], %w{}],
    [{:tds => (tds = {'Full Name' => 'Tan'})}, {:axial_node => 'descendant::*'}] =>
      [tr_axed_path['normalize-space(.)', tds, 'descendant::*', true], %w{e3}],
    # >> {:tds => [...]}
    [{:tds => (tds = ['Tan'])}, {:axial_node => 'self::*'}] =>
      [tr_axed_path['normalize-space(.)', tds, 'self::*', true], %w{}],
    [{:tds => (tds = ['Tan'])}, {:axial_node => 'descendant::*'}] =>
      [tr_axed_path['normalize-space(.)', tds, 'descendant::*', true], %w{e3}],
    # >> [:tds]
    [[:tds], {:axial_node => 'self::*'}] =>
      [tr_axed_path['normalize-space(.)', nil, 'self::*', true], %w{e2 e3 e5 e6}],
    [[:tds], {:axial_node => 'descendant::*'}] =>
      [tr_axed_path['normalize-space(.)', nil, 'descendant::*', true], %w{e2 e3 e6}],
  }.each do |(match_attrs, config), (expected_path, expected_ids)|

    describe '> match attrs as %s, & w config as %s' % [match_attrs.inspect, config.inspect] do

      before { XPF.configure(:reset) }

      should 'return xpath as described' do
        each_xpf {|xpf| xpf.send(:tr, match_attrs, config).should.equal(expected_path) }
      end

      should "return xpath that match intended node(s)" do
        each_xpf {|xpf| ids[xpf.send(:tr, match_attrs, config)].should.equal(expected_ids) }
      end

    end

  end

  # NOTE: These are all we need for 'a basic html element' shared spec.
  require File.join(File.dirname(__FILE__), '..', 'generic_integration', 'basic_element_shared_spec')
  before { @element = :tr }
  behaves_like 'a basic element'

end
