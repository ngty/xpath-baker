require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'matchers', 'html', 'spec_helpers')
require File.join(File.dirname(__FILE__), '..', 'generic', 'basic_element_shared_spec')
require 'xpath-baker/html'

describe "Generating xpath for html <tr/>" do

  extend XPathBaker::Spec::Helpers::TD

  before do
    XPathBaker.configure(:reset) do |config|
      config.scope = '//'
      config.normalize_space = false
      config.case_sensitive = true
      config.axial_node = :self
      config.match_ordering = false
    end
  end

  after do
    XPathBaker.configure(:reset)
  end

  [
  # /////////////////////////////////////////////////////////////////////////////
  # >> {:tds => {...}}
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> string value
      debug = __LINE__,
      content = %|
        <tr id="i1"><th>#</th><th>Full Name</th></tr>
        <tr id="i2"><td>1</td><td>Jane Loh</td></tr>
        <tr id="i3"><td>2</td><td>John Tan</td></tr>
      |,
      match_attrs = {:tds => (tds = {'#' => 1, 'Full Name' => 'Jane Loh'})},
      config = {},
      expected_ids = %w{i2},
      expected_path = (
        comparison = lambda{|v| string_comparison(content_exprs, v) }
        '//tr[./td[%s]/../td[%s]]' % tds.map do |field, val|
          th = %|ancestor::table[1]//th[%s][1]| % comparison[field]
          'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val]]
        end
      ),
    ], [
    # >> array value (sorted)
      debug = __LINE__,
      content,
      match_attrs = {:tds => (tds = {%w{#} => %w{1}, %w{Name Full} => %w{Loh Jane}})},
      config = {:match_ordering => true},
      expected_ids = %w{},
      expected_path = (
        comparison = lambda{|v| sorted_token_comparison(content_exprs, v) }
        '//tr[./td[%s]/../td[%s]]' % tds.map do |field, val|
          th = %|ancestor::table[1]//th[%s][1]| % comparison[field]
          'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val]]
        end
      ),
    ], [
    # >> array value (unsorted)
      debug = __LINE__,
      content,
      match_attrs,
      config = {:match_ordering => false},
      expected_ids = %w{i2},
      expected_path = (
        comparison = lambda{|v| unsorted_token_comparison(content_exprs, v) }
        '//tr[./td[%s]/../td[%s]]' % tds.map do |field, val|
          th = %|ancestor::table[1]//th[%s][1]| % comparison[field]
          'count(%s/preceding-sibling::th)+1][%s][%s' % [th, th, comparison[val]]
        end
      ),
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> {:tds => [...]}
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> string value (sorted)
      debug = __LINE__,
      content = %|
        <tr id="i1"><th>#</th><th>Full Name</th></tr>
        <tr id="i2"><td>1</td><td>Jane Loh</td></tr>
        <tr id="i3"><td>2</td><td>John Tan</td></tr>
      |,
      match_attrs = {:tds => (tds = ['Jane Loh', '1'])},
      config = {:match_ordering => true},
      expected_ids = %w{},
      expected_path = (
        '//tr[./td[%s]/following-sibling::td[%s]]' % tds.map do |val|
          string_comparison(content_exprs, val)
        end
      ),
    # >> string value (unsorted)
      debug = __LINE__,
      content,
      match_attrs,
      config = {:match_ordering => false},
      expected_ids = %w{},
      expected_path = (
        '//tr[./td[%s]/../td[%s]]' % tds.map do |val|
          string_comparison(content_exprs, val)
        end
      ),
    ], [
    # >> array value (sorted)
      debug = __LINE__,
      content,
      match_attrs = {:tds => (tds = [%w{1}, %w{Loh Jane}])},
      config = {:match_ordering => true},
      expected_ids = %w{},
      expected_path = (
        '//tr[./td[%s]/following-sibling::td[%s]]' % tds.map do |val|
          sorted_token_comparison(content_exprs, val)
        end
      ),
    ], [
    # >> array value (unsorted)
      debug = __LINE__,
      content,
      match_attrs,
      config = {:match_ordering => false},
      expected_ids = %w{i2},
      expected_path = (
        '//tr[./td[%s]/../td[%s]]' % tds.map do |val|
          unsorted_token_comparison(content_exprs, val)
        end
      ),
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [:tds, ...]
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> string value (sorted)
      debug = __LINE__,
      content = %|
        <tr id="i1"><th>#</th><th>Full Name</th></tr>
        <tr id="i2"><td>1</td><td>Jane Loh</td></tr>
        <tr id="i3"></tr>
      |,
      match_attrs = [:tds],
      config = {},
      expected_ids = %w{i2},
      expected_path = '//tr[./td[(text()) or (.)]]',
    ],
  ].each do |(debug, content, match_attrs, config, expected_ids, expected_path)|

    describe '> match attrs as %s, & config as %s [#%s]' % [match_attrs.inspect, config.inspect, debug] do

      get_ids = lambda do |path|
        Nokogiri::HTML(%|<html><body><table>#{content}</table></body></html>|).
          xpath(path).map{|node| node.attribute('id').to_s }
      end

      should 'return xpath as described' do
        each_baker {|baker| baker.send(:tr, match_attrs, config).should.equal(expected_path) }
      end

      should "return xpath that match intended node(s)" do
        each_baker {|baker| get_ids[baker.send(:tr, match_attrs, config)].should.equal(expected_ids) }
      end

    end

  end

  before { @element = :tr }
  behaves_like 'a basic element'

end
