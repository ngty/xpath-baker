def xpf_single_match_attrs_args
  [
  # /////////////////////////////////////////////////////////////////////////////
  # {:include_inner_text => ...}
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> all inner text ... {:include_inner_text => ...} has NO effect !!
      debug = __LINE__,
      content = '<%s id="i1">AA<%s>BB</%s></%s><%s id="i2">AABB</%s>',
      match_attrs = {:+ => 'AABB'},
      configs = [{:include_inner_text => false}, {:include_inner_text => true}, %w{i}, %w{!i}],
      expected = ['//%s[./self::*[.="AABB"]]', %w{i1 i2}]
    ], [
    # >> direct inner text ... {:include_inner_text => ...} has NO effect !!
      debug = __LINE__,
      content,
      match_attrs = {:- => 'AA'},
      configs,
      expected = ['//%s[./self::*[text()="AA"]]', %w{i1}]
    ], [
    # >> any inner text ... {:include_inner_text => ...} has NO effect !!
      debug = __LINE__,
      content,
      match_attrs = {:* => 'AA'},
      configs,
      expected = ['//%s[./self::*[(text()="AA") or (.="AA")]]', %w{i1}]
    ], [
      debug = __LINE__,
      content,
      match_attrs = {:* => 'AABB'},
      configs,
      expected = ['//%s[./self::*[(text()="AABB") or (.="AABB")]]', %w{i1 i2}]
    ], [
    # >> configurable inner text ... {:include_inner_text => ...} has effect !!
      debug = __LINE__,
      content,
      match_attrs = {:~ => 'AA'},
      configs = [{:include_inner_text => false}, %w{!i}],
      expected = ['//%s[./self::*[text()="AA"]]', %w{i1}],
    ], [
      debug = __LINE__,
      content,
      match_attrs = {:~ => 'AABB'},
      configs = [{:include_inner_text => true}, %w{i}],
      expected = ['//%s[./self::*[.="AABB"]]', %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{i}],
      configs = [%w{!i}],
      expected,
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:case_sensitive => ...}
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      debug = __LINE__,
      content = '<%s id="i1">aabb<e1>cc</e1></%s><%s id="i2">AABB</%s>',
      match_attrs = {:* => 'AABB'},
      configs = [{:case_sensitive => true}, %w{c}],
      expected = ['//%s[./self::*[(text()="AABB") or (.="AABB")]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:case_sensitive => false}, %w{!c}],
      expected = [%|//%s[./self::*[(#{translate_casing('text()')}="aabb") or (#{translate_casing('.')}="aabb")]]|, %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!c}],
      configs = [%w{c}],
      expected,
    ], [
    # >> all inner text
      debug = __LINE__,
      content = '<%s id="i1">aabb</%s><%s id="i2">AABB</%s>',
      match_attrs = {:+ => 'AABB'},
      configs = [{:case_sensitive => true}, %w{c}],
      expected = ['//%s[./self::*[.="AABB"]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:case_sensitive => false}, %w{!c}],
      expected = [%|//%s[./self::*[#{translate_casing('.')}="aabb"]]|, %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!c}],
      configs = [%w{c}],
      expected
    ], [
    # >> element
      debug = __LINE__,
      content = '<%s id="i1"><e1>aabb</e1></%s><%s id="i2"><e1>AABB</e1></%s>',
      match_attrs = {:e1 => 'AABB'},
      configs = [{:case_sensitive => true}, %w{c}],
      expected = ['//%s[./self::*[e1="AABB"]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:case_sensitive => false}, %w{!c}],
      expected = [%|//%s[./self::*[#{translate_casing('e1')}="aabb"]]|, %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs,  %w{!c}],
      configs = [%w{c}],
      expected,
    ], [
    # >> attribute
      debug = __LINE__,
      content = '<%s id="i1" a1="aabb" /><%s id="i2" a1="AABB" />',
      match_attrs = {:@a1 => 'AABB'},
      configs = [{:case_sensitive => true}, %w{c}],
      expected = ['//%s[./self::*[@a1="AABB"]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:case_sensitive => false}, %w{!c}],
      expected = [%|//%s[./self::*[#{translate_casing('@a1')}="aabb"]]|, %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!c}],
      configs = [%w{c}],
      expected,
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:normalize_space => ...}
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      debug = __LINE__,
      content = '<%s id="i1"> AABB<e1>CC</e1></%s><%s id="i2">AABB</%s>',
      match_attrs = {:* => 'AABB'},
      configs = [{:normalize_space => true}, %w{n}],
      expected = ['//%s[./self::*[(normalize-space(text())="AABB") or (normalize-space(.)="AABB")]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:normalize_space => false}, %w{!n}],
      expected = [%|//%s[./self::*[(text()="AABB") or (.="AABB")]]|, %w{i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!n}],
      configs = [%w{n}],
      expected,
    ], [
    # >> all inner text
      debug = __LINE__,
      content = '<%s id="i1"> AABB </%s><%s id="i2">AABB</%s>',
      match_attrs = {:+ => 'AABB'},
      configs = [{:normalize_space => true}, %w{n}],
      expected = ['//%s[./self::*[normalize-space(.)="AABB"]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:normalize_space => false}, %w{!n}],
      expected = [%|//%s[./self::*[.="AABB"]]|, %w{i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!n}],
      configs = [%w{n}],
      expected,
    ], [
    # >> element
      debug = __LINE__,
      content = '<%s id="i1"><e1> AABB</e1></%s><%s id="i2"><e1>AABB</e1></%s>',
      match_attrs = {:e1 => 'AABB'},
      configs = [{:normalize_space => true}, %w{n}],
      expected = ['//%s[./self::*[normalize-space(e1)="AABB"]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:normalize_space => false}, %w{!n}],
      expected = [%|//%s[./self::*[e1="AABB"]]|, %w{i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!n}],
      configs = [%w{n}],
      expected,
    ], [
    # >> attribute
      debug = __LINE__,
      content = '<%s id="i1" a1=" AABB" /><%s id="i2" a1="AABB" />',
      match_attrs = {:@a1 => 'AABB'},
      configs = [{:normalize_space => true}, %w{n}],
      expected = ['//%s[./self::*[normalize-space(@a1)="AABB"]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:normalize_space => false}, %w{!n}],
      expected = [%|//%s[./self::*[@a1="AABB"]]|, %w{i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{!n}],
      configs = [%w{n}],
      expected,
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:axial_node => ...}
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      debug = __LINE__,
      content = '<%s id="i1"><e0>AABB<e1>CC</e1></e0></%s><%s id="i2">AABB</%s>',
      match_attrs = {:* => 'AABB'},
      configs = [{:axial_node => :self}, %w{self}],
      expected = ['//%s[./self::*[(text()="AABB") or (.="AABB")]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:axial_node => :descendant_or_self}, %w{descendant-or-self}],
      expected = [%|//%s[./descendant-or-self::*[(text()="AABB") or (.="AABB")]]|, %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{descendant-or-self}],
      configs = [%w{self}],
      expected,
    ], [
    # >> all inner text
      debug = __LINE__,
      content = '<e1>AA<%s id="i1">BB</%s></e1><%s id="i2">AABB</%s>',
      match_attrs = {:+ => 'AABB'},
      configs = [{:axial_node => :self}, %w{self}],
      expected = ['//%s[./self::*[.="AABB"]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:axial_node => :ancestor_or_self}, %w{ancestor-or-self}],
      expected = [%|//%s[./ancestor-or-self::*[.="AABB"]]|, %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{ancestor-or-self}],
      configs = [{:axial_node => :self}, %w{self}],
      expected,
    ], [
    # >> element
      debug = __LINE__,
      content = '<%s id="i1"><e0><e1>AABB</e1></e0></%s><%s id="i2"><e1>AABB</e1></%s>',
      match_attrs = {:e1 => 'AABB'},
      configs = [{:axial_node => :self}, %w{self}],
      expected = ['//%s[./self::*[e1="AABB"]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:axial_node => :descendant_or_self}, %w{descendant-or-self}],
      expected = [%|//%s[./descendant-or-self::*[e1="AABB"]]|, %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{descendant-or-self}],
      configs = [{:axial_node => :self}, %w{self}],
      expected,
    ], [
    # >> attribute
      debug = __LINE__,
      content = '<%s id="i1"><e1 a1="AABB"/></%s><%s id="i2" a1="AABB" />',
      match_attrs = {:@a1 => 'AABB'},
      configs = [{:axial_node => :self}, %w{self}],
      expected = ['//%s[./self::*[@a1="AABB"]]', %w{i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:axial_node => :descendant_or_self}, %w{descendant-or-self}],
      expected = [%|//%s[./descendant-or-self::*[@a1="AABB"]]|, %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{descendant-or-self}],
      configs = [{:axial_node => :self}, %w{self}],
      expected,
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:position => ...} (undesirably affecting match-attr generated predicate)
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      debug = __LINE__,
      content = '<%s id="i1">AABB</%s><%s id="i2">AABB</%s>',
      match_attrs = {:* => 'AABB'},
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[(text()="AABB") or (.="AABB")][2]][2]', %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:position => 0}, %w{0}],
      expected = [%|//%s[./self::*[(text()="AABB") or (.="AABB")]]|, %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{0}],
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[(text()="AABB") or (.="AABB")]][2]', %w{i2}]
    ], [
    # >> all inner text
      debug = __LINE__,
      content = '<%s id="i1"><e1>AABB</e1></%s><%s id="i2">AABB</%s>',
      match_attrs = {:+ => 'AABB'},
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[.="AABB"][2]][2]', %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:position => 0}, %w{0}],
      expected = [%|//%s[./self::*[.="AABB"]]|, %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{0}],
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[.="AABB"]][2]', %w{i2}]
    ], [
    # >> element
      debug = __LINE__,
      content = '<%s id="i1"><e1>AABB</e1></%s><%s id="i2"><e1>AABB</e1></%s>',
      match_attrs = {:e1 => 'AABB'},
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[e1="AABB"][2]][2]', %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:position => 0}, %w{0}],
      expected = [%|//%s[./self::*[e1="AABB"]]|, %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{0}],
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[e1="AABB"]][2]', %w{i2}]
    ], [
    # >> attribute
      debug = __LINE__,
      content = '<%s id="i1" a1="AABB"/><%s id="i2" a1="AABB" />',
      match_attrs = {:@a1 => 'AABB'},
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[@a1="AABB"][2]][2]', %w{}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:position => 0}, %w{0}],
      expected = [%|//%s[./self::*[@a1="AABB"]]|, %w{i1 i2}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{0}],
      configs = [{:position => 2}, %w{2}],
      expected = ['//%s[./self::*[@a1="AABB"]][2]', %w{i2}]
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:scope => ...} (won't affect any match-attr generated predicate)
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      debug = __LINE__,
      content = '<%s id="i1">AABB</%s><%s id="i2">AABB</%s>',
      match_attrs = {:* => 'AABB'},
      configs = [{:scope => '/root/'}, %w{/root/}],
      expected = ['/root/%s[./self::*[(text()="AABB") or (.="AABB")]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '/boo/'}, %w{/boo/}],
      expected = [%|/boo/%s[./self::*[(text()="AABB") or (.="AABB")]]|, %w{}]
    ], [
      # >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{/root/}],
      configs,
      expected,
    ], [
    # >> all inner text
      debug = __LINE__,
      content = '<%s id="i1"><e1>AABB</e1></%s><%s id="i2">AABB</%s>',
      match_attrs = {:+ => 'AABB'},
      configs = [{:scope => '/root/'}, %w{/root/}],
      expected = ['/root/%s[./self::*[.="AABB"]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '/boo/'}, %w{/boo/}],
      expected = [%|/boo/%s[./self::*[.="AABB"]]|, %w{}]
    ], [
      # >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{/root/}],
      configs,
      expected,
    ], [
    # >> element
      debug = __LINE__,
      content = '<%s id="i1"><e1>AABB</e1></%s><%s id="i2"><e1>AABB</e1></%s>',
      match_attrs = {:e1 => 'AABB'},
      configs = [{:scope => '/root/'}, %w{/root/}],
      expected = ['/root/%s[./self::*[e1="AABB"]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '/boo/'}, %w{/boo/}],
      expected = [%|/boo/%s[./self::*[e1="AABB"]]|, %w{}]
    ], [
      # >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{/root/}],
      configs,
      expected,
    ], [
    # >> attribute
      debug = __LINE__,
      content = '<%s id="i1" a1="AABB"/><%s id="i2" a1="AABB" />',
      match_attrs = {:@a1 => 'AABB'},
      configs = [{:scope => '/root/'}, %w{/root/}],
      expected = ['/root/%s[./self::*[@a1="AABB"]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:scope => '/boo/'}, %w{/boo/}],
      expected = [%|/boo/%s[./self::*[@a1="AABB"]]|, %w{}]
    ], [
      # >> this is how common config can be overridden !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{/root/}],
      configs,
      expected,
    ],
  # /////////////////////////////////////////////////////////////////////////////
  # {:greedy => ...} (won't affect any match-attr generated predicate)
  # /////////////////////////////////////////////////////////////////////////////
    [
    # >> any inner text
      debug = __LINE__,
      content = '<%s id="i1">AABB<%s id="i3"></%s></%s><%s id="i2">AABB</%s>',
      match_attrs = {:* => 'AABB'},
      configs = [{:greedy => true}, %w{g}],
      expected = ['//%s[./self::*[(text()="AABB") or (.="AABB")]]', %w{i1 i2}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = [%|//%s[not(.//%s)][./self::*[(text()="AABB") or (.="AABB")]]|, %w{i2}]
    ], [
      # >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
    # >> all inner text
      debug = __LINE__,
      content = '<%s id="i1"><%s id="i3">AABB</%s></%s><%s id="i2">AABB</%s>',
      match_attrs = {:+ => 'AABB'},
      configs = [{:greedy => true}, %w{g}],
      expected = ['//%s[./self::*[.="AABB"]]', %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = [%|//%s[not(.//%s)][./self::*[.="AABB"]]|, %w{i2 i3}]
    ], [
      # >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
    # >> element
      debug = __LINE__,
      content = '<%s id="i1"><e1>AABB</e1><%s id="i3"><e1>AABB</e1></%s></%s><%s id="i2"><e1>AABB</e1></%s>',
      match_attrs = {:e1 => 'AABB'},
      configs = [{:greedy => true}, %w{g}],
      expected = ['//%s[./self::*[e1="AABB"]]', %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = [%|//%s[not(.//%s)][./self::*[e1="AABB"]]|, %w{i2 i3}]
    ], [
      # >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ], [
    # >> attribute
      debug = __LINE__,
      content = '<%s id="i1" a1="AABB"><%s id="i3" a1="AABB" /><%s id="i2" a1="AABB" />',
      match_attrs = {:@a1 => 'AABB'},
      configs = [{:greedy => true}, %w{g}],
      expected = ['//%s[./self::*[@a1="AABB"]]', %w{i1 i2 i3}]
    ], [
      debug = __LINE__,
      content,
      match_attrs,
      configs = [{:greedy => false}, %w{!g}],
      expected = [%|//%s[not(.//%s)][./self::*[@a1="AABB"]]|, %w{i2 i3}]
    ], [
      # >> overriding common config has no effect !!
      debug = __LINE__,
      content,
      match_attrs = [match_attrs, %w{g}],
      configs,
      expected,
    ],
  ].map do |debug, content, match_attrs, configs, expected|
    configs.map do |config|
      [debug, xpf_ids_proc(content), match_attrs, config, xpf_expected_proc(expected)]
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
      configs = [{:scope => '//boot/', :position => nil, :greedy => true}, %w{//boot/ 0 g}],
      expected = ['//boot/%s', %w{}],
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
    :match_ordering     => true,
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

