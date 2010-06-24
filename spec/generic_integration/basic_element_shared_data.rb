def xpf_multiple_match_attrs_args
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
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[e1][e3][2]][./self::*[@a1][2]][2]', %w{}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [match_attrs], [[match_attrs], {config}], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[:e1, :e3], [[:@a1], {:position => 0}]],
      configs,
      expected = ['//%s[./self::*[e1][e3][2]][./self::*[@a1]][2]', %w{}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [[match_attrs], [config]], [match_attrs], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[[:e1, :e3], %w{0}], [:@a1]],
      configs,
      expected = ['//%s[./self::*[e1][e3]][./self::*[@a1][2]][2]', %w{}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [match_attrs], [match_attrs]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[:e1, :e3], [:@a1]],
      configs = [[]],
      expected = ['//%s[./self::*[e1][e3]][./self::*[@a1]]', %w{i1}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> {match_attrs}, {match_attrs}, {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content = %|
        <%s id="i1" a1="ee">aa<e1>cc</e1></%s>
        <%s id="i2" a2="ee">bb<e1>cc</e1></%s>
        <%s id="i3" a1="ee">aa<e1>dd</e1></%s>
      |,
      match_attrs = [{:e1 => 'cc', :@a1 => 'ee'}, {:- => 'aa'}],
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[@a1="ee"][e1="cc"][2]][./self::*[text()="aa"][2]][2]', %w{}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> {match_attrs}, [{match_attrs}, {config}], {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [{:e1 => 'cc', :@a1 => 'ee'}, [{:- => 'aa'}, {:position => 0}]],
      configs,
      expected = ['//%s[./self::*[@a1="ee"][e1="cc"][2]][./self::*[text()="aa"]][2]', %w{}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> [{match_attrs}, [config]], {match_attrs}, {config}|[config]
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [[{:e1 => 'cc', :@a1 => 'ee'}, %w{0}], {:- => 'aa'}],
      configs,
      expected = ['//%s[./self::*[@a1="ee"][e1="cc"]][./self::*[text()="aa"][2]][2]', %w{}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # >> {match_attrs}, {match_attrs}
  # /////////////////////////////////////////////////////////////////////////////
    [
      debug = __LINE__,
      content,
      match_attrs = [{:e1 => 'cc', :@a1 => 'ee'}, {:- => 'aa'}],
      configs = [[]],
      expected = ['//%s[./self::*[@a1="ee"][e1="cc"]][./self::*[text()="aa"]]', %w{i1}]
    ],
  ].map do |debug, content, match_attrs, configs, expected|
    configs.map do |config|
      [debug, xpf_ids_proc(content), match_attrs, config, xpf_expected_proc(expected)]
    end
  end.flatten(1)
end

def xpf_single_match_attrs_args
  [
  # /////////////////////////////////////////////////////////////////////////////
  # {:include_inner_text => ...}
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> all inner text ... {:include_inner_text => ...} has NO effect !!
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1">AA<%s id="i3"> BB</%s></%s><%s id="i2">AA BB</%s>',
      match_attrs = {:+ => 'AA BB'},
      configs = [{:include_inner_text => false}, {:include_inner_text => true}, %w{i}, %w{!i}],
      expected = ['//%s[./self::*[.="AA BB"]]', %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:+ => %w{BB}},
      configs = [{:include_inner_text => false}, {:include_inner_text => true}, %w{i}, %w{!i}],
      expected = [%|//%s[./self::*[#{check_tokens('.',%w{"BB"})}]]|, %w{i1 i2 i3}]
    ], [
      ## >> nil value (presence checking)
      _debug = __LINE__,
      _content = '<%s id="i1"><e1> </e1></%s><%s id="i2"/><%s id="i3"></%s>',
      _match_attrs = [:+],
      _configs = [{:include_inner_text => false}, {:include_inner_text => true}, %w{i}, %w{!i}],
      _expected = [%|//%s[./self::*[.]]|, %w{i1 i2 i3}]
    ], [
    # >> direct inner text ... {:include_inner_text => ...} has NO effect !!
      ## >> string value (equality checking)
      debug = __LINE__,
      content,
      match_attrs = {:- => 'AA'},
      configs,
      expected = ['//%s[./self::*[text()="AA"]]', %w{i1}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:- => %w{BB}},
      configs,
      expected = [%|//%s[./self::*[#{check_tokens('text()',%w{"BB"})}]]|, %w{i2 i3}]
    ], [
      ## >> nil value (presence checking)
      _debug = __LINE__,
      _content = '<%s id="i1"><e1> </e1></%s><%s id="i2"/><%s id="i3"> </%s>',
      _match_attrs = [:-],
      _configs = [{:include_inner_text => false}, {:include_inner_text => true}, %w{i}, %w{!i}],
      _expected = [%|//%s[./self::*[text()]]|, %w{i3}]
    ], [
    # >> any inner text ... {:include_inner_text => ...} has NO effect !!
      ## >> string value (equality checking)
      debug = __LINE__,
      content,
      match_attrs = {:* => 'AA'},
      configs,
      expected = ['//%s[./self::*[(text()="AA") or (.="AA")]]', %w{i1}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:* => 'AA BB'},
      configs,
      expected = ['//%s[./self::*[(text()="AA BB") or (.="AA BB")]]', %w{i1 i2}]
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"><e1> </e1></%s><%s id="i2"/><%s id="i3"></%s>',
      _match_attrs = [:*],
      _configs = [{:include_inner_text => false}, {:include_inner_text => true}, %w{i}, %w{!i}],
      _expected = [%|//%s[./self::*[(text()) or (.)]]|, %w{i1 i2 i3}]
    ], [
    # >> configurable inner text ... {:include_inner_text => ...} has effect !!
      ## >> string value (equality checking)
      debug = __LINE__,
      content,
      match_attrs = {:~ => 'AA'},
      configs = [{:include_inner_text => false}, %w{!i}],
      expected = ['//%s[./self::*[text()="AA"]]', %w{i1}],
    ], [
      debug = __LINE__,
      content,
      match_attrs = {:~ => 'AA BB'},
      configs = [{:include_inner_text => true}, %w{i}],
      expected = ['//%s[./self::*[.="AA BB"]]', %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:~ => %w{BB}},
      configs = [{:include_inner_text => false}, %w{!i}],
      expected = [%|//%s[./self::*[#{check_tokens('text()',%w{"BB"})}]]|, %w{i2 i3}],
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:include_inner_text => true}, %w{i}],
      expected = [%|//%s[./self::*[#{check_tokens('.',%w{"BB"})}]]|, %w{i1 i2 i3}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{i}],
      configs = [%w{!i}],
      expected,
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{i}],
      _configs = [%w{!i}],
      _expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"><e1> </e1></%s><%s id="i2"/><%s id="i3"> </%s>',
      _match_attrs = [:~],
      _configs = [{:include_inner_text => false}, %w{!i}],
      _expected = [%|//%s[./self::*[text()]]|, %w{i3}],
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:include_inner_text => true}, %w{i}],
      _expected = [%|//%s[./self::*[.]]|, %w{i1 i2 i3}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{i}],
      _configs = [%w{!i}],
      _expected,
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:case_sensitive => ...}
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1">aa bb<e1>cc</e1></%s><%s id="i2">AA BB</%s>',
      match_attrs = {:* => 'AA BB'},
      configs = [{:case_sensitive => true}, %w{c}],
      expected = ['//%s[./self::*[(text()="AA BB") or (.="AA BB")]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:case_sensitive => false}, %w{!c}],
      expected = [%|//%s[./self::*[(#{translate_casing('text()')}="aa bb") or (#{translate_casing('.')}="aa bb")]]|, %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:* => %w{BB}},
      configs = [{:case_sensitive => true}, %w{c}],
      expected = [%|//%s[./self::*[(#{check_tokens('text()',%w{"BB"})}) or (#{check_tokens('.',%w{"BB"})})]]|, %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:case_sensitive => false}, %w{!c}],
      expected = [%|//%s[./self::*[(#{check_tokens(translate_casing('text()'),%w{"bb"})}) or (#{check_tokens(translate_casing('.'),%w{"bb"})})]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!c}],
      configs = [%w{c}],
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"><e1> </e1></%s><%s id="i2"/><%s id="i3"></%s>',
      _match_attrs = [:*],
      _configs = [{:case_sensitive => true}, {:case_sensitive => false}, %w{c}, %w{!c}],
      _expected = ['//%s[./self::*[(text()) or (.)]]', %w{i1 i2 i3}]
    ], [
    # >> all inner text
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1">aa bb</%s><%s id="i2">AA BB</%s>',
      match_attrs = {:+ => 'AA BB'},
      configs = [{:case_sensitive => true}, %w{c}],
      expected = ['//%s[./self::*[.="AA BB"]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:case_sensitive => false}, %w{!c}],
      expected = [%|//%s[./self::*[#{translate_casing('.')}="aa bb"]]|, %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:+ => %w{BB}},
      configs = [{:case_sensitive => true}, %w{c}],
      expected = [%|//%s[./self::*[#{check_tokens('.',%w{"BB"})}]]|, %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:case_sensitive => false}, %w{!c}],
      expected = [%|//%s[./self::*[#{check_tokens(translate_casing('.'),%w{"bb"})}]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!c}],
      configs = [%w{c}],
      expected
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"><e1> </e1></%s><%s id="i2"/><%s id="i3"></%s>',
      _match_attrs = [:+],
      _configs = [{:case_sensitive => true}, {:case_sensitive => false}, %w{c}, %w{!c}],
      _expected = ['//%s[./self::*[.]]', %w{i1 i2 i3}]
    ], [
    # >> element
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"><e1>aa bb</e1></%s><%s id="i2"><e1>AA BB</e1></%s>',
      match_attrs = {:e1 => 'AA BB'},
      configs = [{:case_sensitive => true}, %w{c}],
      expected = ['//%s[./self::*[e1="AA BB"]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:case_sensitive => false}, %w{!c}],
      expected = [%|//%s[./self::*[#{translate_casing('e1')}="aa bb"]]|, %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:e1 => %w{BB}},
      configs = [{:case_sensitive => true}, %w{c}],
      expected = [%|//%s[./self::*[#{check_tokens('e1',%w{"BB"})}]]|, %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:case_sensitive => false}, %w{!c}],
      expected = [%|//%s[./self::*[#{check_tokens(translate_casing('e1'),%w{"bb"})}]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs,  %w{!c}],
      configs = [%w{c}],
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"><e1> </e1></%s><%s id="i2"/><%s id="i3"><e1/></%s>',
      _match_attrs = [:e1],
      _configs = [{:case_sensitive => true}, {:case_sensitive => false}, %w{c}, %w{!c}],
      _expected = ['//%s[./self::*[e1]]', %w{i1 i3}]
    ], [
    # >> attribute
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1" a1="aa bb" /><%s id="i2" a1="AA BB" />',
      match_attrs = {:@a1 => 'AA BB'},
      configs = [{:case_sensitive => true}, %w{c}],
      expected = ['//%s[./self::*[@a1="AA BB"]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:case_sensitive => false}, %w{!c}],
      expected = [%|//%s[./self::*[#{translate_casing('@a1')}="aa bb"]]|, %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:@a1 => %w{BB}},
      configs = [{:case_sensitive => true}, %w{c}],
      expected = [%|//%s[./self::*[#{check_tokens('@a1',%w{"BB"})}]]|, %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:case_sensitive => false}, %w{!c}],
      expected = [%|//%s[./self::*[#{check_tokens(translate_casing('@a1'),%w{"bb"})}]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!c}],
      configs = [%w{c}],
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1" a1="" /><%s id="i2"/>',
      _match_attrs = [:@a1],
      _configs = [{:case_sensitive => true}, {:case_sensitive => false}, %w{c}, %w{!c}],
      _expected = ['//%s[./self::*[@a1]]', %w{i1}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:normalize_space => ...}
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"> AA BB<e1>CC</e1></%s><%s id="i2">AA BB</%s>',
      match_attrs = {:* => 'AA BB'},
      configs = [{:normalize_space => true}, %w{n}],
      expected = ['//%s[./self::*[(normalize-space(text())="AA BB") or (normalize-space(.)="AA BB")]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:normalize_space => false}, %w{!n}],
      expected = [%|//%s[./self::*[(text()="AA BB") or (.="AA BB")]]|, %w{i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:* => %w{BB}},
      configs = [{:normalize_space => true}, %w{n}],
      expected = [%|//%s[./self::*[(#{check_tokens('normalize-space(text())',%w{"BB"})}) or (#{check_tokens('normalize-space(.)',%w{"BB"})})]]|, %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:normalize_space => false}, %w{!n}],
      expected = [%|//%s[./self::*[(#{check_tokens('text()',%w{"BB"})}) or (#{check_tokens('.',%w{"BB"})})]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!n}],
      configs = [%w{n}],
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"> </%s><%s id="i2">AA</%s>',
      _match_attrs = [:*],
      _configs = [{:normalize_space => true}, %w{n}],
      _expected = ['//%s[./self::*[(normalize-space(text())) or (normalize-space(.))]]', %w{i2}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:normalize_space => false}, %w{!n}],
      _expected = [%|//%s[./self::*[(text()) or (.)]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{!n}],
      _configs = [%w{n}],
      _expected,
    ], [
    # >> all inner text
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"> AA BB </%s><%s id="i2">AA BB</%s>',
      match_attrs = {:+ => 'AA BB'},
      configs = [{:normalize_space => true}, %w{n}],
      expected = ['//%s[./self::*[normalize-space(.)="AA BB"]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:normalize_space => false}, %w{!n}],
      expected = [%|//%s[./self::*[.="AA BB"]]|, %w{i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:+ => %w{BB}},
      configs = [{:normalize_space => true}, %w{n}],
      expected = [%|//%s[./self::*[#{check_tokens('normalize-space(.)',%w{"BB"})}]]|, %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:normalize_space => false}, %w{!n}],
      expected = [%|//%s[./self::*[#{check_tokens('.',%w{"BB"})}]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!n}],
      configs = [%w{n}],
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"> </%s><%s id="i2">AA</%s>',
      _match_attrs = [:+],
      _configs = [{:normalize_space => true}, %w{n}],
      _expected = ['//%s[./self::*[normalize-space(.)]]', %w{i2}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:normalize_space => false}, %w{!n}],
      _expected = [%|//%s[./self::*[.]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{!n}],
      _configs = [%w{n}],
      _expected,
    ], [
    # >> element
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"><e1> AA BB</e1></%s><%s id="i2"><e1>AA BB</e1></%s>',
      match_attrs = {:e1 => 'AA BB'},
      configs = [{:normalize_space => true}, %w{n}],
      expected = ['//%s[./self::*[normalize-space(e1)="AA BB"]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:normalize_space => false}, %w{!n}],
      expected = [%|//%s[./self::*[e1="AA BB"]]|, %w{i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:e1 => %w{BB}},
      configs = [{:normalize_space => true}, %w{n}],
      expected = [%|//%s[./self::*[#{check_tokens('normalize-space(e1)',%w{"BB"})}]]|, %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:normalize_space => false}, %w{!n}],
      expected = [%|//%s[./self::*[#{check_tokens('e1',%w{"BB"})}]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!n}],
      configs = [%w{n}],
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"><e1/></%s><%s id="i2"><e1>AA BB</e1></%s>',
      _match_attrs = [:e1],
      _configs = [{:normalize_space => true}, %w{n}],
      _expected = ['//%s[./self::*[normalize-space(e1)]]', %w{i2}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:normalize_space => false}, %w{!n}],
      _expected = [%|//%s[./self::*[e1]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{!n}],
      _configs = [%w{n}],
      _expected,
    ], [
    # >> attribute
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1" a1=" AA BB" /><%s id="i2" a1="AA BB" />',
      match_attrs = {:@a1 => 'AA BB'},
      configs = [{:normalize_space => true}, %w{n}],
      expected = ['//%s[./self::*[normalize-space(@a1)="AA BB"]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:normalize_space => false}, %w{!n}],
      expected = [%|//%s[./self::*[@a1="AA BB"]]|, %w{i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:@a1 => %w{BB}},
      configs = [{:normalize_space => true}, %w{n}],
      expected = [%|//%s[./self::*[#{check_tokens('normalize-space(@a1)',%w{"BB"})}]]|, %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:normalize_space => false}, %w{!n}],
      expected = [%|//%s[./self::*[#{check_tokens('@a1',%w{"BB"})}]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!n}],
      configs = [%w{n}],
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1" a1="" /><%s id="i2" a1="AA BB" /><%s id="i3" />',
      _match_attrs = [:@a1],
      _configs = [{:normalize_space => true}, %w{n}],
      _expected = ['//%s[./self::*[normalize-space(@a1)]]', %w{i2}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:normalize_space => false}, %w{!n}],
      _expected = ['//%s[./self::*[@a1]]', %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{!n}],
      _configs = [%w{n}],
      _expected,
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:match_ordering => ...} (only applicable for tokens matching)
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      debug = __LINE__,
      content = '<%s id="i1">AA <e1>BB</e1></%s><%s id="i2">AA BB</%s>',
      match_attrs = {:* => %w{AA BB}},
      configs = [{:match_ordering => true}, %w{o}],
      expected = [%|//%s[./self::*[(#{check_tokens('text()',%w{"AA" "BB"},true)}) or (#{check_tokens('.',%w{"AA" "BB"},true)})]]|, %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs = {:* => %w{BB AA}},
      configs = [{:match_ordering => true}, %w{o}],
      expected = [%|//%s[./self::*[(#{check_tokens('text()',%w{"BB" "AA"},true)}) or (#{check_tokens('.',%w{"BB" "AA"},true)})]]|, %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs = {:* => %w{BB AA}},
      configs = [{:match_ordering => false}, %w{!o}],
      expected = [%|//%s[./self::*[(#{check_tokens('text()',%w{"BB" "AA"},false)}) or (#{check_tokens('.',%w{"BB" "AA"},false)})]]|, %w{i1 i2}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!o}],
      configs = [%w{o}],
      expected,
    ], [
    # >> all inner text
      debug = __LINE__,
      content,
      match_attrs = {:+ => %w{AA BB}},
      configs = [{:match_ordering => true}, %w{o}],
      expected = [%|//%s[./self::*[#{check_tokens('.',%w{"AA" "BB"},true)}]]|, %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs = {:+ => %w{BB AA}},
      configs = [{:match_ordering => true}, %w{o}],
      expected = [%|//%s[./self::*[#{check_tokens('.',%w{"BB" "AA"},true)}]]|, %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs = {:+ => %w{BB AA}},
      configs = [{:match_ordering => false}, %w{!o}],
      expected = [%|//%s[./self::*[#{check_tokens('.',%w{"BB" "AA"},false)}]]|, %w{i1 i2}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!o}],
      configs = [%w{o}],
      expected,
    ], [
    # >> element
      debug = __LINE__,
      content = '<%s id="i1"><e1>AA BB</e1></%s><%s id="i2"><e1>AA BB</e1></%s>',
      match_attrs = {:e1 => %w{AA BB}},
      configs = [{:match_ordering => true}, %w{o}],
      expected = [%|//%s[./self::*[#{check_tokens('e1',%w{"AA" "BB"},true)}]]|, %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs = {:e1 => %w{BB AA}},
      configs = [{:match_ordering => true}, %w{o}],
      expected = [%|//%s[./self::*[#{check_tokens('e1',%w{"BB" "AA"},true)}]]|, %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs = {:e1 => %w{BB AA}},
      configs = [{:match_ordering => false}, %w{!o}],
      expected = [%|//%s[./self::*[#{check_tokens('e1',%w{"BB" "AA"},false)}]]|, %w{i1 i2}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!o}],
      configs = [%w{o}],
      expected,
    ], [
    # >> attribute
      debug = __LINE__,
      content = '<%s id="i1" a1="AA BB"/><%s id="i2" a1="AA BB" />',
      match_attrs = {:@a1 => %w{AA BB}},
      configs = [{:match_ordering => true}, %w{o}],
      expected = [%|//%s[./self::*[#{check_tokens('@a1',%w{"AA" "BB"},true)}]]|, %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs = {:@a1 => %w{BB AA}},
      configs = [{:match_ordering => true}, %w{o}],
      expected = [%|//%s[./self::*[#{check_tokens('@a1',%w{"BB" "AA"},true)}]]|, %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs = {:@a1 => %w{BB AA}},
      configs = [{:match_ordering => false}, %w{!o}],
      expected = [%|//%s[./self::*[#{check_tokens('@a1',%w{"BB" "AA"},false)}]]|, %w{i1 i2}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!o}],
      configs = [%w{o}],
      expected,
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:axial_node => ...}
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"><e0>AA BB<e1>CC</e1></e0></%s><%s id="i2">AA BB</%s>',
      match_attrs = {:* => 'AA BB'},
      configs = [{:axial_node => :self}, %w{self}],
      expected = ['//%s[./self::*[(text()="AA BB") or (.="AA BB")]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:axial_node => :descendant_or_self}, %w{descendant-or-self}],
      expected = [%|//%s[./descendant-or-self::*[(text()="AA BB") or (.="AA BB")]]|, %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:* => %w{BB}},
      configs = [{:axial_node => :self}, %w{self}],
      expected = [%|//%s[./self::*[(#{check_tokens('text()',%w{"BB"})}) or (#{check_tokens('.',%w{"BB"})})]]|, %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:axial_node => :descendant_or_self}, %w{descendant-or-self}],
      expected = [%|//%s[./descendant-or-self::*[(#{check_tokens('text()',%w{"BB"})}) or (#{check_tokens('.',%w{"BB"})})]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{descendant-or-self}],
      configs = [%w{self}],
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"/><%s id="i2"><e1/></%s>',
      _match_attrs = [:*],
      _configs = [{:axial_node => :self}, %w{self}],
      _expected = ['//%s[./self::*[(text()) or (.)]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:axial_node => :descendant}, %w{descendant}],
      _expected = [%|//%s[./descendant::*[(text()) or (.)]]|, %w{i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{descendant}],
      _configs = [%w{self}],
      _expected,
    ], [
    # >> all inner text
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<e1>AA BB<%s id="i1"/></e1><%s id="i2">AA BB</%s>',
      match_attrs = {:+ => 'AA BB'},
      configs = [{:axial_node => :self}, %w{self}],
      expected = ['//%s[./self::*[.="AA BB"]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:axial_node => :ancestor_or_self}, %w{ancestor-or-self}],
      expected = [%|//%s[./ancestor-or-self::*[.="AA BB"]]|, %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:+ => %w{BB}},
      configs = [{:axial_node => :self}, %w{self}],
      expected = [%|//%s[./self::*[#{check_tokens('.',%w{"BB"})}]]|, %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:axial_node => :ancestor_or_self}, %w{ancestor-or-self}],
      expected = [%|//%s[./ancestor-or-self::*[#{check_tokens('.',%w{"BB"})}]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{ancestor-or-self}],
      configs = [{:axial_node => :self}, %w{self}],
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"/><%s id="i2"><e1/></%s>',
      _match_attrs = [:+],
      _configs = [{:axial_node => :self}, %w{self}],
      _expected = ['//%s[./self::*[.]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:axial_node => :descendant}, %w{descendant}],
      _expected = [%|//%s[./descendant::*[.]]|, %w{i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{descendant}],
      _configs = [%w{self}],
      _expected,
    ], [
    # >> element
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"><e0><e1>AA BB</e1></e0></%s><%s id="i2"><e1>AA BB</e1></%s>',
      match_attrs = {:e1 => 'AA BB'},
      configs = [{:axial_node => :self}, %w{self}],
      expected = ['//%s[./self::*[e1="AA BB"]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:axial_node => :descendant_or_self}, %w{descendant-or-self}],
      expected = [%|//%s[./descendant-or-self::*[e1="AA BB"]]|, %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:e1 => %w{BB}},
      configs = [{:axial_node => :self}, %w{self}],
      expected = [%|//%s[./self::*[#{check_tokens('e1',%w{"BB"})}]]|, %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:axial_node => :descendant_or_self}, %w{descendant-or-self}],
      expected = [%|//%s[./descendant-or-self::*[#{check_tokens('e1',%w{"BB"})}]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{descendant-or-self}],
      configs = [{:axial_node => :self}, %w{self}],
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"><e0><e1/></e0></%s><%s id="i2"><e1/></%s>',
      _match_attrs = [:e1],
      _configs = [{:axial_node => :self}, %w{self}],
      _expected = ['//%s[./self::*[e1]]', %w{i2}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:axial_node => :descendant_or_self}, %w{descendant-or-self}],
      _expected = [%|//%s[./descendant-or-self::*[e1]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{descendant-or-self}],
      _configs = [%w{self}],
      _expected,
    ], [
    # >> attribute
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"><e1 a1="AA BB"/></%s><%s id="i2" a1="AA BB" />',
      match_attrs = {:@a1 => 'AA BB'},
      configs = [{:axial_node => :self}, %w{self}],
      expected = ['//%s[./self::*[@a1="AA BB"]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:axial_node => :descendant_or_self}, %w{descendant-or-self}],
      expected = [%|//%s[./descendant-or-self::*[@a1="AA BB"]]|, %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:@a1 => %w{BB}},
      configs = [{:axial_node => :self}, %w{self}],
      expected = [%|//%s[./self::*[#{check_tokens('@a1',%w{"BB"})}]]|, %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:axial_node => :descendant_or_self}, %w{descendant-or-self}],
      expected = [%|//%s[./descendant-or-self::*[#{check_tokens('@a1',%w{"BB"})}]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{descendant-or-self}],
      configs = [{:axial_node => :self}, %w{self}],
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"><e1 a1="AA BB"/></%s><%s id="i2" a1="AA BB" />',
      _match_attrs = [:@a1],
      _configs = [{:axial_node => :self}, %w{self}],
      _expected = ['//%s[./self::*[@a1]]', %w{i2}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:axial_node => :descendant_or_self}, %w{descendant-or-self}],
      _expected = [%|//%s[./descendant-or-self::*[@a1]]|, %w{i1 i2}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{descendant-or-self}],
      _configs = [%w{self}],
      _expected,
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:position => ...}
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1">AA BB</%s><%s id="i2">AA BB</%s>',
      match_attrs = {:* => 'AA BB'},
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[(text()="AA BB") or (.="AA BB")][2]][2]', %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:position => 0}, %w{0}],
      expected = [%|//%s[./self::*[(text()="AA BB") or (.="AA BB")]]|, %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:* => %w{BB}},
      configs = [{:position => 2}, %w{2}],
      expected = [%|//%s[./self::*[(#{check_tokens('text()',%w{"BB"})}) or (#{check_tokens('.',%w{"BB"})})][2]][2]|, %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:position => 0}, %w{0}],
      expected = [%|//%s[./self::*[(#{check_tokens('text()',%w{"BB"})}) or (#{check_tokens('.',%w{"BB"})})]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{0}],
      configs = [%w{2}],
      expected = [%|//%s[./self::*[(#{check_tokens('text()',%w{"BB"})}) or (#{check_tokens('.',%w{"BB"})})]][2]|, %w{i2}]
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"/><%s id="i2"/>',
      _match_attrs = [:*],
      _configs = [{:position => 2}, %w{2}],
      _expected = ['//%s[./self::*[(text()) or (.)][2]][2]', %w{}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:position => 0}, %w{0}],
      _expected = [%|//%s[./self::*[(text()) or (.)]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{0}],
      _configs = [%w{2}],
      _expected = [%|//%s[./self::*[(text()) or (.)]][2]|, %w{i2}]
    ], [
    # >> all inner text
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"><e1>AA BB</e1></%s><%s id="i2">AA BB</%s>',
      match_attrs = {:+ => 'AA BB'},
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[.="AA BB"][2]][2]', %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:position => 0}, %w{0}],
      expected = [%|//%s[./self::*[.="AA BB"]]|, %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:+ => %w{BB}},
      configs = [{:position => 2}, %w{2}],
      expected = [%|//%s[./self::*[#{check_tokens('.',%w{"BB"})}][2]][2]|, %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:position => 0}, %w{0}],
      expected = [%|//%s[./self::*[#{check_tokens('.',%w{"BB"})}]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{0}],
      configs = [%w{2}],
      expected = [%|//%s[./self::*[#{check_tokens('.',%w{"BB"})}]][2]|, %w{i2}]
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"/><%s id="i2"/>',
      _match_attrs = [:+],
      _configs = [{:position => 2}, %w{2}],
      _expected = ['//%s[./self::*[.][2]][2]', %w{}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:position => 0}, %w{0}],
      _expected = [%|//%s[./self::*[.]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{0}],
      _configs = [%w{2}],
      _expected = [%|//%s[./self::*[.]][2]|, %w{i2}]
    ], [
    # >> element
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"><e1>AA BB</e1></%s><%s id="i2"><e1>AA BB</e1></%s>',
      match_attrs = {:e1 => 'AA BB'},
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[e1="AA BB"][2]][2]', %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:position => 0}, %w{0}],
      expected = [%|//%s[./self::*[e1="AA BB"]]|, %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:e1 => %w{BB}},
      configs = [{:position => 2}, %w{2}],
      expected = [%|//%s[./self::*[#{check_tokens('e1',%w{"BB"})}][2]][2]|, %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:position => 0}, %w{0}],
      expected = [%|//%s[./self::*[#{check_tokens('e1',%w{"BB"})}]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{0}],
      configs = [{:position => 2}, %w{2}],
      expected = [%|//%s[./self::*[#{check_tokens('e1',%w{"BB"})}]][2]|, %w{i2}]
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1"><e1/></%s><%s id="i2"><e1/></%s>',
      _match_attrs = [:e1],
      _configs = [{:position => 2}, %w{2}],
      _expected = ['//%s[./self::*[e1][2]][2]', %w{}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:position => 0}, %w{0}],
      _expected = [%|//%s[./self::*[e1]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{0}],
      _configs = [%w{2}],
      _expected = [%|//%s[./self::*[e1]][2]|, %w{i2}]
    ], [
    # >> attribute
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1" a1="AA BB"/><%s id="i2" a1="AA BB" />',
      match_attrs = {:@a1 => 'AA BB'},
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[@a1="AA BB"][2]][2]', %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:position => 0}, %w{0}],
      expected = [%|//%s[./self::*[@a1="AA BB"]]|, %w{i1 i2}]
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:@a1 => %w{BB}},
      configs = [{:position => 2}, %w{2}],
      expected = [%|//%s[./self::*[#{check_tokens('@a1',%w{"BB"})}][2]][2]|, %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:position => 0}, %w{0}],
      expected = [%|//%s[./self::*[#{check_tokens('@a1',%w{"BB"})}]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{0}],
      configs = [{:position => 2}, %w{2}],
      expected = [%|//%s[./self::*[#{check_tokens('@a1',%w{"BB"})}]][2]|, %w{i2}]
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      _content = '<%s id="i1" a1=""/><%s id="i2" a1="AA" />',
      _match_attrs = [:@a1],
      _configs = [{:position => 2}, %w{2}],
      _expected = ['//%s[./self::*[@a1][2]][2]', %w{}]
    ], [
      debug = __LINE__,
      _content,
      _match_attrs,
      _configs = [{:position => 0}, %w{0}],
      _expected = [%|//%s[./self::*[@a1]]|, %w{i1 i2}]
    ], [
      ## >> this is how common config can be overridden !!
      debug = __LINE__,
      _content,
      _match_attrs = [_match_attrs, %w{0}],
      _configs = [%w{2}],
      _expected = [%|//%s[./self::*[@a1]][2]|, %w{i2}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:scope => ...} (won't affect any match-attr generated predicate)
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1">AA BB</%s>',
      match_attrs = {:* => 'AA BB'},
      configs = [{:scope => '//root/'}, %w{//root/}],
      expected = ['//root/%s[./self::*[(text()="AA BB") or (.="AA BB")]]', %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '//awe/some/'}, %w{//awe/some/}],
      expected = ['//awe/some/%s[./self::*[(text()="AA BB") or (.="AA BB")]]', %w{}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{//root/}],
      configs,
      expected,
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:* => %w{BB}},
      configs = [{:scope => '//root/'}, %w{//root/}],
      expected = [%|//root/%s[./self::*[(#{check_tokens('text()',%w{"BB"})}) or (#{check_tokens('.',%w{"BB"})})]]|, %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '//awe/some/'}, %w{//awe/some/}],
      expected = [%|//awe/some/%s[./self::*[(#{check_tokens('text()',%w{"BB"})}) or (#{check_tokens('.',%w{"BB"})})]]|, %w{}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{//root/}],
      configs,
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      content,
      match_attrs = [:*],
      configs = [{:scope => '//root/'}, %w{//root/}],
      expected = [%|//root/%s[./self::*[(text()) or (.)]]|, %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '//awe/some/'}, %w{//awe/some/}],
      expected = [%|//awe/some/%s[./self::*[(text()) or (.)]]|, %w{}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{//root/}],
      configs,
      expected,
    ], [
    # >> all inner text
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1">AA BB</%s>',
      match_attrs = {:+ => 'AA BB'},
      configs = [{:scope => '//root/'}, %w{//root/}],
      expected = ['//root/%s[./self::*[.="AA BB"]]', %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '//awe/some/'}, %w{//awe/some/}],
      expected = ['//awe/some/%s[./self::*[.="AA BB"]]', %w{}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{//root/}],
      configs,
      expected,
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:+ => %w{BB}},
      configs = [{:scope => '//root/'}, %w{//root/}],
      expected = [%|//root/%s[./self::*[#{check_tokens('.',%w{"BB"})}]]|, %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '//awe/some/'}, %w{//awe/some/}],
      expected = [%|//awe/some/%s[./self::*[#{check_tokens('.',%w{"BB"})}]]|, %w{}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{//root/}],
      configs,
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      content,
      match_attrs = [:+],
      configs = [{:scope => '//root/'}, %w{//root/}],
      expected = [%|//root/%s[./self::*[.]]|, %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '//awe/some/'}, %w{//awe/some/}],
      expected = [%|//awe/some/%s[./self::*[.]]|, %w{}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{//root/}],
      configs,
      expected,
    ], [
    # >> element
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"><e1>AA BB</e1></%s>',
      match_attrs = {:e1 => 'AA BB'},
      configs = [{:scope => '//root/'}, %w{//root/}],
      expected = ['//root/%s[./self::*[e1="AA BB"]]', %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '//awe/some/'}, %w{//awe/some/}],
      expected = ['//awe/some/%s[./self::*[e1="AA BB"]]', %w{}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{//root/}],
      configs,
      expected,
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:e1 => %w{BB}},
      configs = [{:scope => '//root/'}, %w{//root/}],
      expected = [%|//root/%s[./self::*[#{check_tokens('e1',%w{"BB"})}]]|, %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '//awe/some/'}, %w{//awe/some/}],
      expected = [%|//awe/some/%s[./self::*[#{check_tokens('e1',%w{"BB"})}]]|, %w{}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{//root/}],
      configs,
      expected,
    ], [
    ## >> nil value (presence checking)
      debug = __LINE__,
      content,
      match_attrs = [:e1],
      configs = [{:scope => '//root/'}, %w{//root/}],
      expected = [%|//root/%s[./self::*[e1]]|, %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '//awe/some/'}, %w{//awe/some/}],
      expected = [%|//awe/some/%s[./self::*[e1]]|, %w{}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{//root/}],
      configs,
      expected,
    ], [
    # >> attribute
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1" a1="AA BB"/>',
      match_attrs = {:@a1 => 'AA BB'},
      configs = [{:scope => '//root/'}, %w{//root/}],
      expected = ['//root/%s[./self::*[@a1="AA BB"]]', %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '//awe/some/'}, %w{//awe/some/}],
      expected = ['//awe/some/%s[./self::*[@a1="AA BB"]]', %w{}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{//root/}],
      configs,
      expected,
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:@a1 => %w{BB}},
      configs = [{:scope => '//root/'}, %w{//root/}],
      expected = [%|//root/%s[./self::*[#{check_tokens('@a1',%w{"BB"})}]]|, %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '//awe/some/'}, %w{//awe/some/}],
      expected = [%|//awe/some/%s[./self::*[#{check_tokens('@a1',%w{"BB"})}]]|, %w{}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{//root/}],
      configs,
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      content,
      match_attrs = [:@a1],
      configs = [{:scope => '//root/'}, %w{//root/}],
      expected = [%|//root/%s[./self::*[@a1]]|, %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '//awe/some/'}, %w{//awe/some/}],
      expected = [%|//awe/some/%s[./self::*[@a1]]|, %w{}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{//root/}],
      configs,
      expected,
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:greedy => ...} (won't affect any match-attr generated predicate)
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"><%s id="i3">AA BB</%s></%s><%s id="i2">AA BB</%s>',
      match_attrs = {:* => 'AA BB'},
      configs = [{:greedy => true}, %w{g}],
      expected = ['//%s[./self::*[(text()="AA BB") or (.="AA BB")]]', %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = ['//%s[not(.//%s)][./self::*[(text()="AA BB") or (.="AA BB")]]', %w{i2 i3}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:* => %w{BB}},
      configs = [{:greedy => true}, %w{g}],
      expected = [%|//%s[./self::*[(#{check_tokens('text()',%w{"BB"})}) or (#{check_tokens('.',%w{"BB"})})]]|, %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = [%|//%s[not(.//%s)][./self::*[(#{check_tokens('text()',%w{"BB"})}) or (#{check_tokens('.',%w{"BB"})})]]|, %w{i2 i3}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      content,
      match_attrs = [:*],
      configs = [{:greedy => true}, %w{g}],
      expected = [%|//%s[./self::*[(text()) or (.)]]|, %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = [%|//%s[not(.//%s)][./self::*[(text()) or (.)]]|, %w{i2 i3}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
    # >> all inner text
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"><%s id="i3">AA BB</%s></%s><%s id="i2">AA BB</%s>',
      match_attrs = {:+ => 'AA BB'},
      configs = [{:greedy => true}, %w{g}],
      expected = ['//%s[./self::*[.="AA BB"]]', %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = ['//%s[not(.//%s)][./self::*[.="AA BB"]]', %w{i2 i3}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:+ => %w{BB}},
      configs = [{:greedy => true}, %w{g}],
      expected = [%|//%s[./self::*[#{check_tokens('.',%w{"BB"})}]]|, %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = [%|//%s[not(.//%s)][./self::*[#{check_tokens('.',%w{"BB"})}]]|, %w{i2 i3}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      content,
      match_attrs = [:+],
      configs = [{:greedy => true}, %w{g}],
      expected = [%|//%s[./self::*[.]]|, %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = [%|//%s[not(.//%s)][./self::*[.]]|, %w{i2 i3}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
    # >> element
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1"><e1>AA BB</e1><%s id="i3"><e1>AA BB</e1></%s></%s><%s id="i2"><e1>AA BB</e1></%s>',
      match_attrs = {:e1 => 'AA BB'},
      configs = [{:greedy => true}, %w{g}],
      expected = ['//%s[./self::*[e1="AA BB"]]', %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = ['//%s[not(.//%s)][./self::*[e1="AA BB"]]', %w{i2 i3}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:e1 => %w{BB}},
      configs = [{:greedy => true}, %w{g}],
      expected = [%|//%s[./self::*[#{check_tokens('e1',%w{"BB"})}]]|, %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = [%|//%s[not(.//%s)][./self::*[#{check_tokens('e1',%w{"BB"})}]]|, %w{i2 i3}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
    ## >> nil value (presence checking)
      debug = __LINE__,
      content,
      match_attrs = [:e1],
      configs = [{:greedy => true}, %w{g}],
      expected = [%|//%s[./self::*[e1]]|, %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = [%|//%s[not(.//%s)][./self::*[e1]]|, %w{i2 i3}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
    # >> attribute
      ## >> string value (equality checking)
      debug = __LINE__,
      content = '<%s id="i1" a1="AA BB"><%s id="i3" a1="AA BB"/></%s><%s id="i2" a1="AA BB"/>',
      match_attrs = {:@a1 => 'AA BB'},
      configs = [{:greedy => true}, %w{g}],
      expected = ['//%s[./self::*[@a1="AA BB"]]', %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = ['//%s[not(.//%s)][./self::*[@a1="AA BB"]]', %w{i2 i3}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
      ## >> array value (token matching)
      debug = __LINE__,
      content,
      match_attrs = {:@a1 => %w{BB}},
      configs = [{:greedy => true}, %w{g}],
      expected = [%|//%s[./self::*[#{check_tokens('@a1',%w{"BB"})}]]|, %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = [%|//%s[not(.//%s)][./self::*[#{check_tokens('@a1',%w{"BB"})}]]|, %w{i2 i3}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
      ## >> nil value (presence checking)
      debug = __LINE__,
      content,
      match_attrs = [:@a1],
      configs = [{:greedy => true}, %w{g}],
      expected = [%|//%s[./self::*[@a1]]|, %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = [%|//%s[not(.//%s)][./self::*[@a1]]|, %w{i2 i3}]
    ], [
      ## >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ],
  ].map do |debug, content, match_attrs, configs, expected|
    configs.map do |config|
      [debug, xpf_ids_proc(content), [match_attrs], config, xpf_expected_proc(expected)]
    end
  end.flatten(1)
end

def xpf_no_match_attrs_args
  ignored_config = {
    :case_sensitive     => [true, false],
    :match_ordering     => [true, false],
    :normalize_space    => [true, false],
    :include_inner_text => [true, false],
    :axial_node         => [:self, :descendant, :ancestor, :child, :parent],
    :attribute_matcher  => [XPF::Matchers::Attribute, Class.new{}], # no error thrown means OK
    :element_matcher    => [XPF::Matchers::Element, Class.new{}],   # no error thrown means OK
    :any_text_matcher   => [XPF::Matchers::AnyText, Class.new{}],   # no error thrown means OK
    :text_matcher       => [XPF::Matchers::Text, Class.new{}],      # no error thrown means OK
    :literal_matcher    => [XPF::Matchers::Literal, Class.new{}],   # no error thrown means OK
    :group_matcher      => [XPF::Matchers::Group, Class.new{}],     # no error thrown means OK
  }

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
      [debug, xpf_ids_proc(content), config, ignored_config, xpf_expected_proc(expected)]
    end
  end.flatten(1)
end

def xpf_default_config
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
    :element_matcher    => XPF::Matchers::Element,
    :attribute_matcher  => XPF::Matchers::Attribute,
    :text_matcher       => XPF::Matchers::Text,
    :any_text_matcher   => XPF::Matchers::AnyText,
    :literal_matcher    => XPF::Matchers::Literal,
    :group_matcher      => XPF::Matchers::Group,
  }
end

def xpf_ids_proc(content)
  lambda do |element, path|
    Nokogiri::XML("<root>%s</root>" % content % ([element]*50)).xpath(path).
      map{|node| node.attribute('id') }.map(&:to_s).sort
  end
end

def xpf_expected_proc(expected)
  lambda do |element, i|
    i.zero? ? (expected[i] % ([element]*50)) : expected[i]
  end
end

