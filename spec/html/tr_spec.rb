require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'xpf/html'

describe "XPF::HTML <tr/> support" do

  tr_path = lambda do |text_comparison, cells, match_ordering|
    test = lambda{|val| %|#{text_comparison}="#{val}"| }
    '//tr[./self::*[%s]]' % (
      case cells
      when nil
        './td[%s]' % text_comparison
      when Hash
        cells.map do |field, val|
          th = %|./ancestor::table[1]//th[#{test[field]}][1]|
          %\./td[count(#{th}/preceding-sibling::th)+1][#{th}][#{test[val]}]\
        end.join('][')
      else
        !match_ordering ? (cells.map {|val| './td[%s]' % test[val] }.join('][')) :
          ('./td[%s]' % cells.map {|val| test[val] }.join(']/following-sibling::td['))
      end
    )
  end

  downcase = lambda do |cells|
    cells.is_a?(Hash) ?
      cells.inject({}){|memo, (field,val)| memo.merge(field.downcase => val.downcase) } :
      cells.map{|val| val.downcase }
  end

  ids = lambda do |path|
    Nokogiri::HTML(%\
      <html>
        <body>
          <table>
            <tr id="e1"><th>#</th> <th>Full <br/> Name</th>
            <tr id="e2"><td> 1</td><td>Jane <br/> Lee</td>
            <tr id="e3"><td>2 </td><td>John <br/> Tan</td>
            <tr id="e4"><td>  </td><td>     <br/>    </td>
            <tr id="e5"><td>  </td><td>     <br/> Poo </td>
          </table>
        </body>
      </html>
    \).xpath(path).map{|node| node.attribute('id').to_s }
  end

  {
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # {:normalize_space => ... }
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # >> {:cells => {...}}
    [{:cells => (cells = {'#' => '2', 'Full Name' => 'John Tan'})}, {:normalize_space => true}] =>
      [tr_path['normalize-space(.)', cells, nil], %w{e3}],
    [{:cells => (cells = {'#' => '2 ', 'Full  Name' => 'John  Tan'})}, {:normalize_space => true}] =>
      [tr_path['normalize-space(.)', cells, nil], %w{}],
    [{:cells => (cells = {'#' => '2 ', 'Full  Name' => 'John  Tan'})}, {:normalize_space => false}] =>
      [tr_path['.', cells, nil], %w{e3}],
    [{:cells => (cells = {'#' => '2', 'Full Name' => 'John Tan'})}, {:normalize_space => false}] =>
      [tr_path['.', cells, nil], %w{}],
    # >> {:cells => [...]}
    [{:cells => (cells = ['2', 'John Tan'])}, {:normalize_space => true}] =>
      [tr_path['normalize-space(.)', cells, true], %w{e3}],
    [{:cells => (cells = ['2 ', 'John  Tan'])}, {:normalize_space => true}] =>
      [tr_path['normalize-space(.)', cells, true], %w{}],
    [{:cells => (cells = ['2 ', 'John  Tan'])}, {:normalize_space => false}] =>
      [tr_path['.', cells, true], %w{e3}],
    [{:cells => (cells = ['2', 'John Tan'])}, {:normalize_space => false}] =>
      [tr_path['.', cells, true], %w{}],
    # >> [:cells]
    [[:cells], {:normalize_space => true}] =>
      [tr_path['normalize-space(.)', nil, nil], %w{e2 e3 e5}],
    [[:cells], {:normalize_space => false}] =>
      [tr_path['.', nil, nil], %w{e2 e3 e4 e5}],
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # {:include_inner_text => ... }
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # >> {:cells => {...}}
    [{:cells => (cells = {'#' => '2', 'Full Name' => 'John Tan'})}, {:include_inner_text => true}] =>
      [tr_path['normalize-space(.)', cells, nil], %w{e3}],
    [{:cells => (cells = {'#' => '2', 'Full' => 'John'})}, {:include_inner_text => true}] =>
      [tr_path['normalize-space(.)', cells, nil], %w{}],
    [{:cells => (cells = {'#' => '2', 'Full Name' => 'John Tan'})}, {:include_inner_text => false}] =>
      [tr_path['normalize-space(text())', cells, nil], %w{}],
    [{:cells => (cells = {'#' => '2', 'Full' => 'John'})}, {:include_inner_text => false}] =>
      [tr_path['normalize-space(text())', cells, nil], %w{e3}],
    # >> {:cells => [...]}
    [{:cells => (cells = ['2', 'John Tan'])}, {:include_inner_text => true}] =>
      [tr_path['normalize-space(.)', cells, true], %w{e3}],
    [{:cells => (cells = ['2', 'John'])}, {:include_inner_text => true}] =>
      [tr_path['normalize-space(.)', cells, true], %w{}],
    [{:cells => (cells = ['2', 'John Tan'])}, {:include_inner_text => false}] =>
      [tr_path['normalize-space(text())', cells, true], %w{}],
    [{:cells => (cells = ['2', 'John'])}, {:include_inner_text => false}] =>
      [tr_path['normalize-space(text())', cells, true], %w{e3}],
    # >> [:cells]
    [[:cells], {:include_inner_text => true}] =>
      [tr_path['normalize-space(.)', nil, nil], %w{e2 e3 e5}],
    [[:cells], {:include_inner_text => false}] =>
      [tr_path['normalize-space(text())', nil, nil], %w{e2 e3}],
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # {:case_sensitive => ... }
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # >> {:cells => {...}}
    [{:cells => (cells = {'#' => '2', 'Full Name' => 'John Tan'})}, {:case_sensitive => true}] =>
      [tr_path['normalize-space(.)', cells, nil], %w{e3}],
    [{:cells => (cells = {'#' => '2', 'full name' => 'john tan'})}, {:case_sensitive => true}] =>
      [tr_path['normalize-space(.)', cells, nil], %w{}],
    [{:cells => (cells = {'#' => '2', 'full name' => 'john tan'})}, {:case_sensitive => false}] =>
      [tr_path[translate_casing('normalize-space(.)'), downcase[cells], nil], %w{e3}],
    [{:cells => (cells = {'#' => '2', 'Full Name' => 'John Tan'})}, {:case_sensitive => false}] =>
      [tr_path[translate_casing('normalize-space(.)'), downcase[cells], nil], %w{e3}],
    # >> {:cells => [...]}
    [{:cells => (cells = ['2', 'John Tan'])}, {:case_sensitive => true}] =>
      [tr_path['normalize-space(.)', cells, true], %w{e3}],
    [{:cells => (cells = ['2', 'john tan'])}, {:case_sensitive => true}] =>
      [tr_path['normalize-space(.)', cells, true], %w{}],
    [{:cells => (cells = ['2', 'john tan'])}, {:case_sensitive => false}] =>
      [tr_path[translate_casing('normalize-space(.)'), downcase[cells], true], %w{e3}],
    [{:cells => (cells = ['2', 'John Tan'])}, {:case_sensitive => false}] =>
      [tr_path[translate_casing('normalize-space(.)'), downcase[cells], true], %w{e3}],
    # >> [:cells] (NA)
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # {:match_ordering => ... }
    # ///////////////////////////////////////////////////////////////////////////////////////////
    # >> {:cells => [...]}
    [{:cells => (cells = ['2', 'John Tan'])}, {:match_ordering => true}] =>
      [tr_path['normalize-space(.)', cells, true], %w{e3}],
    [{:cells => (cells = ['John Tan', '2'])}, {:match_ordering => true}] =>
      [tr_path['normalize-space(.)', cells, true], %w{}],
    [{:cells => (cells = ['2', 'John Tan'])}, {:match_ordering => false}] =>
      [tr_path['normalize-space(.)', cells, false], %w{e3}],
    [{:cells => (cells = ['John Tan', '2'])}, {:match_ordering => false}] =>
      [tr_path['normalize-space(.)', cells, false], %w{e3}],
    # >> [:cells] (NA)
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
  require File.join(File.dirname(__FILE__), 'basic_element_shared_spec')
  before { @element = :tr }
  # behaves_like 'a basic html element'

end
