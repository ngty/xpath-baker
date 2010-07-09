def xpb_multiple_match_attrs_args
  [
  # /////////////////////////////////////////////////////////////////////////////
  # >> [match_attrs], [match_attrs], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content = %|
        <%s id="i1" a1="~"><e1/><e3/></%s>
        <%s id="i2" a2="~"><e1/><e3/></%s>
        <%s id="i3" a1="~"><e2/><e3/></%s>
      |,
      match_attrs = [[:e1, :e3], [:@a1]],
      configs = [{:comparison => '='}, %w{=}],
      expected = ['//%s[self::*[e1][e3]][self::*[@a1]]', %w{i1}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [match_attrs], [[match_attrs], {config}], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[:e1, :e3], [[:@a1], {:comparison => '!'}]],
      configs,
      expected = ['//%s[self::*[e1][e3]][self::*[not(@a1)]]', %w{i2}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [[match_attrs], [config]], [match_attrs], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[[:e1, :e3], %w{!}], [:@a1]],
      configs,
      expected = ['//%s[self::*[not(e1)][not(e3)]][self::*[@a1]]', %w{}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [match_attrs], [match_attrs]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[:e1, :e3], [:@a1]],
      configs = [[]],
      expected = ['//%s[self::*[e1][e3]][self::*[@a1]]', %w{i1}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> {match_attrs}, {match_attrs}, {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content = %|
        <%s id="i1" a1="ee">aa<e1>cc</e1></%s>
        <%s id="i2" a2="ee">bb<e1>cc</e1></%s>
        <%s id="i3" a1="ff">ee<e1>dd</e1></%s>
      |,
      match_attrs = [{:e1 => 'cc', :@a1 => 'ee'}, {:- => 'aa'}],
      configs = [{:comparison => '!'}, %w{!}],
      expected = ['//%s[self::*[not(@a1="ee")][not(e1="cc")]][self::*[not(text()="aa")]]', %w{i3}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> {match_attrs}, [{match_attrs}, {config}], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [{:e1 => 'cc', :@a1 => 'ee'}, [{:- => 'ee'}, {:comparison => '='}]],
      configs,
      expected = ['//%s[self::*[not(@a1="ee")][not(e1="cc")]][self::*[text()="ee"]]', %w{i3}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [{match_attrs}, [config]], {match_attrs}, {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[{:e1 => 'cc', :@a1 => 'ee'}, %w{=}], {:- => 'dd'}],
      configs,
      expected = ['//%s[self::*[@a1="ee"][e1="cc"]][self::*[not(text()="dd")]]', %w{i1}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> {match_attrs}, {match_attrs}
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [{:e1 => 'cc', :@a1 => 'ee'}, {:- => 'aa'}],
      configs = [[]],
      expected = ['//%s[self::*[@a1="ee"][e1="cc"]][self::*[text()="aa"]]', %w{i1}]
    ],
  ].map do |debug, content, match_attrs, configs, expected|
    configs.map do |config|
      [debug, xpb_ids_proc(content), match_attrs, config, xpb_expected_proc(expected)]
    end
  end.flatten(1)
end

def xpb_single_match_attrs_args
  [
  # /////////////////////////////////////////////////////////////////////////////
  # >> [match_attrs], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content = %|
        <%s id="i1" a1="~"><e1/><e3/></%s>
        <%s id="i2" a2="~"><e1/><e3/></%s>
        <%s id="i3" a1="~"><e2/><e4/></%s>
      |,
      match_attrs = [[:e1, :e3]],
      configs = [{:comparison => '='}, %w{=}],
      expected = ['//%s[self::*[e1][e3]]', %w{i1 i2}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [[match_attrs], {config}], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[[:@a1], {:comparison => '!'}]],
      configs,
      expected = ['//%s[self::*[not(@a1)]]', %w{i2}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [[match_attrs], [config]], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[[:e1, :e3], %w{!}]],
      configs,
      expected = ['//%s[self::*[not(e1)][not(e3)]]', %w{i3}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [[match_attrs]], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[[:e1, :e3]]],
      configs = [{:comparison => '!'}, %w{!}],
      expected = ['//%s[self::*[not(e1)][not(e3)]]', %w{i3}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [match_attrs]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[:e1, :e3]],
      configs = [[]],
      expected = ['//%s[self::*[e1][e3]]', %w{i1 i2}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> {match_attrs}, {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content = %|
        <%s id="i1" a1="ee">aa<e1>cc</e1></%s>
        <%s id="i2" a2="ee">bb<e1>cc</e1></%s>
        <%s id="i3" a1="ff">ee<e1>dd</e1></%s>
      |,
      match_attrs = [{:e1 => 'cc', :@a1 => 'ee'}],
      configs = [{:comparison => '!'}, %w{!}],
      expected = ['//%s[self::*[not(@a1="ee")][not(e1="cc")]]', %w{i3}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [{match_attrs}, {config}], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[{:- => 'ee'}, {:comparison => '='}]],
      configs,
      expected = ['//%s[self::*[text()="ee"]]', %w{i3}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [{match_attrs}], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[{:e1 => 'cc', :@a1 => 'ee'}]],
      configs,
      expected = ['//%s[self::*[not(@a1="ee")][not(e1="cc")]]', %w{i3}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> {match_attrs}
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [{:e1 => 'cc', :@a1 => 'ee'}],
      configs = [[]],
      expected = ['//%s[self::*[@a1="ee"][e1="cc"]]', %w{i1}]
    ],
  ].map do |debug, content, match_attrs, configs, expected|
    configs.map do |config|
      [debug, xpb_ids_proc(content), match_attrs, config, xpb_expected_proc(expected)]
    end
  end.flatten(1)
end

def xpb_no_match_attrs_args
  [
  # ///////////////////////////////////////////////////////////////////////////////////////
  # {:greedy => ...}
  # ///////////////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content = '<%s id="i1"><%s id="i4">AA</%s></%s><%s id="i2">BB</%s><%s id="i3">CC</%s>',
      configs = [{:scope => '//', :position => nil, :greedy => true}, %w{// 0 g}],
      expected = ['//%s', %w{i1 i2 i3 i4}],
    ], [
      debug = __LINE__,
      content,
      configs = [{:scope => '//', :position => nil, :greedy => false}, %w{// 0 !g}],
      expected = ['//%s[not(.//%s)]', %w{i2 i3 i4}],
    ],
  # ///////////////////////////////////////////////////////////////////////////////////////
  # {:scope => ...}
  # ///////////////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content = '<%s id="i1">AA</%s><%s id="i2">BB</%s><%s id="i3">CC</%s>',
      configs = [{:scope => '//', :position => nil, :greedy => true}, %w{// 0 g}],
      expected = ['//%s', %w{i1 i2 i3}],
    ], [
      debug = __LINE__,
      content,
      configs = [{:scope => '//root/', :position => nil, :greedy => true}, %w{//root/ 0 g}],
      expected = ['//root/%s', %w{i1 i2 i3}],
    ], [
      debug = __LINE__,
      content,
      configs = [{:scope => '//awe/some/', :position => nil, :greedy => true}, %w{//awe/some/ 0 g}],
      expected = ['//awe/some/%s', %w{}],
    ],
  # ///////////////////////////////////////////////////////////////////////////////////////
  # {:position => ...}
  # ///////////////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      configs = [{:scope => '//', :position => '>2', :greedy => true}, %w{// >2 g}],
      expected = ['//%s[position()>2]', %w{i3}],
    ], [
      debug = __LINE__,
      content,
      configs = [{:scope => '//', :position => '!>2', :greedy => true}, %w{// !>2 g}],
      expected = ['//%s[not(position()>2)]', %w{i1 i2}],
    ], [
      debug = __LINE__,
      content,
      configs = [{:scope => '//', :position => '>2^', :greedy => true}, %w{// >2^ g}],
      expected = ['//%s[position()>2]', %w{i3}],
    ], [
      debug = __LINE__,
      content,
      configs = [{:scope => '//', :position => '>2$', :greedy => true}, %w{// >2$ g}],
      expected = ['//%s[position()>2]', %w{i3}],
    ],
  ].map do |debug, content, configs, expected|
    configs.map do |config|
      [debug, xpb_ids_proc(content), config, xpb_expected_proc(expected)]
    end
  end.flatten(1)
end

def xpb_default_config
  {
    :greedy             => true,
    :case_sensitive     => true,
    :match_ordering     => false,
    :normalize_space    => false,
    :include_inner_text => true,
    :scope              => '//',
    :position           => nil,
    :axial_node         => 'self::*',
    # NOTE: The followings are working, but not covered yet !!
    :element_matcher    => XPB::Matchers::Element,
    :attribute_matcher  => XPB::Matchers::Attribute,
    :text_matcher       => XPB::Matchers::Text,
    :any_text_matcher   => XPB::Matchers::AnyText,
    :literal_matcher    => XPB::Matchers::Literal,
    :group_matcher      => XPB::Matchers::Group,
  }
end

def xpb_ids_proc(content)
  lambda do |element, path|
    Nokogiri::XML("<root>%s</root>" % content % ([element]*50)).xpath(path).
      map{|node| node.attribute('id') }.map(&:to_s).sort
  end
end

def xpb_expected_proc(expected)
  lambda do |element, i|
    i.zero? ? (expected[i] % ([element]*50)) : expected[i]
  end
end

