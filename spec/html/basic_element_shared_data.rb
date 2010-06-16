def xpf_multiple_match_attrs_args
  contents = lambda do |element, path|
    Nokogiri::HTML(%\
      <html>
        <body>
          <#{element} id="e1" attr1=" AB BC "> A <span attr2="XX"> Bz </span></#{element}>
          <#{element} id="e2" attr1=" CD DE "> C <span attr2="YY"> Dw </span></#{element}>
          <#{element} id="e3" attr1=" AB BC "> E <span attr2="XX">    </span></#{element}>
          <#{element} id="e4" attr1=" ab bc "> G                             </#{element}>
          <#{element} id="e5"                > G <span attr2="ZZ">    </span></#{element}>
          <#{element} id="e6" attr1=" "      > C <span attr2="YY"> Dz </span></#{element}>
          <#{element} id="e7" attr1=" AB BC "> F <span attr2="YY"> Dz </span></#{element}>
        </body>
      </html>
    \).xpath(path).map(&:text)
  end
  {
    [[[[:text], {:axis => 'descendant::span'}], [{:attr1 => 'AB BC'},{}]], {:position => 2}] => lambda{|e| [
      expected_path  = %|//#{e}[./descendant::span[normalize-space(.)]][./self::*[normalize-space(@attr1)="AB BC"]][2]|,
      expected_nodes = [' F  Dz ']
    ] },
    [[[[:text], {:axis => 'descendant::span'}], {:attr1 => 'AB BC'}], {:position => 2}] => lambda{|e| [
      expected_path  = %|//#{e}[./descendant::span[normalize-space(.)]][./self::*[normalize-space(@attr1)="AB BC"][2]][2]|,
      expected_nodes = []
    ] },
    [[[{:attr1 => 'AB BC'},{}], [[:text], {:axis => 'descendant::span'}]], {:position => 2}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="AB BC"]][./descendant::span[normalize-space(.)]][2]|,
      expected_nodes = [' F  Dz ']
    ] },
    [[{:attr1 => 'AB BC'}, [[:text], {:axis => 'descendant::span'}]], {:position => 2}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="AB BC"][2]][./descendant::span[normalize-space(.)]][2]|,
      expected_nodes = []
    ] },
  }.inject({}) {|memo, (args, expectations)| memo.merge([contents] + args => expectations) }
end

def xpf_single_match_attrs_non_generic_args
  ignored_config, contents = {}, lambda do |element, path|
    Nokogiri::HTML(%\
      <html>
        <body>
          <#{element} attr1=" AB BC "> A <span attr2="XX"> Bz </span></#{element}>
          <#{element} attr1=" CD DE "> C <span attr2="YY"> Dw </span></#{element}>
        </body>
      </html>
    \).xpath(path).map(&:text)
  end
  {
    # ///////////////////////////////////////////////////////////////////////////
    # {:position => ...}
    # ///////////////////////////////////////////////////////////////////////////
    # >> text
    [{:text => 'C Dw'}, {:position => nil}, {:position => 1}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(.)="C Dw"]][1]|,
      expected_nodes = [' C  Dw ']
    ] },
    [{:text => 'C Dw'}, {:position => nil}, {:position => '1$'}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(.)="C Dw"]][1]|,
      expected_nodes = [' C  Dw ']
    ] },
    [{:text => 'C Dw'}, {:position => nil}, {:position => '^1'}] => lambda{|e| [
      expected_path  = %|//#{e}[1][./self::*[normalize-space(.)="C Dw"]]|,
      expected_nodes = []
    ] },
    [{:text => 'C Dw'}, {:position => 1}, {:position => nil}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(.)="C Dw"][1]]|,
      expected_nodes = [' C  Dw ']
    ] },
    [{:text => 'C Dw'}, {:position => '1$'}, {:position => nil}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(.)="C Dw"][1]]|,
      expected_nodes = [' C  Dw ']
    ] },
    [{:text => 'C Dw'}, {:position => '^1'}, {:position => nil}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[1][normalize-space(.)="C Dw"]]|,
      expected_nodes = [' C  Dw ']
    ] },
    # >> attr
    [{:attr1 => 'CD DE'}, {:position => nil}, {:position => 1}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="CD DE"]][1]|,
      expected_nodes = [' C  Dw ']
    ] },
    [{:attr1 => 'CD DE'}, {:position => nil}, {:position => '1$'}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="CD DE"]][1]|,
      expected_nodes = [' C  Dw ']
    ] },
    [{:attr1 => 'CD DE'}, {:position => nil}, {:position => '^1'}] => lambda{|e| [
      expected_path  = %|//#{e}[1][./self::*[normalize-space(@attr1)="CD DE"]]|,
      expected_nodes = []
    ] },
    [{:attr1 => 'CD DE'}, {:position => 1}, {:position => nil}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="CD DE"][1]]|,
      expected_nodes = [' C  Dw ']
    ] },
    [{:attr1 => 'CD DE'}, {:position => '1$'}, {:position => nil}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="CD DE"][1]]|,
      expected_nodes = [' C  Dw ']
    ] },
    [{:attr1 => 'CD DE'}, {:position => '^1'}, {:position => nil}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[1][normalize-space(@attr1)="CD DE"]]|,
      expected_nodes = [' C  Dw ']
    ] },

    # ///////////////////////////////////////////////////////////////////////////
    # {:scope => ...}
    # ///////////////////////////////////////////////////////////////////////////
    # >> text
    [{:text => 'C Dw'}, {:scope => '//'}, {:scope => '//body/'}] => lambda{|e| [
      expected_path  = %|//body/#{e}[./self::*[normalize-space(.)="C Dw"]]|,
      expected_nodes = [' C  Dw ']
    ] },
    [{:text => 'C Dw'}, {:scope => '//'}, {:scope => '//xoo/'}] => lambda{|e| [
      expected_path  = %|//xoo/#{e}[./self::*[normalize-space(.)="C Dw"]]|,
      expected_nodes = []
    ] },
    # >> attr
    [{:attr1 => 'CD DE'}, {:scope => '//'}, {:scope => '//body/'}] => lambda{|e| [
      expected_path  = %|//body/#{e}[./self::*[normalize-space(@attr1)="CD DE"]]|,
      expected_nodes = [' C  Dw ']
    ] },
    [{:attr1 => 'CD DE'}, {:scope => '//'}, {:scope => '//xoo/'}] => lambda{|e| [
      expected_path  = %|//xoo/#{e}[./self::*[normalize-space(@attr1)="CD DE"]]|,
      expected_nodes = []
    ] },
  }.inject({}){|memo, args| memo.merge([contents, ignored_config] + args[0] => args[1]) }
end

def xpf_single_match_attrs_generic_args
  ignored_config, alternative_config = {}, {
    :normalize_space    => (booleans = {true => false, false => true}),
    :include_inner_text => booleans,
    :case_sensitive     => booleans,
    :match_ordering     => booleans,
    :scope              => {'//' => '//body/', '//body/' => '//xoo/', '//xoo/' => '//'},
    :position           => {nil => 2, 2 => nil},
    :axis               => {:self => :descendant, :ancestor => self, :descendant => :ancestor},
    # :attribute_matcher  => XPF::Matchers::Attribute,
    # :text_matcher       => XPF::Matchers::Text,
    # :literal_matcher    => XPF::Matchers::Literal,
    # :group_matcher      => XPF::Matchers::Group,
  }

  contents = lambda do |element, path|
    Nokogiri::HTML(%\
      <html>
        <body>
          <#{element} attr1=" AB BC "> A <span attr2="XX"> Bz </span></#{element}>
          <#{element} attr1=" CD DE "> C <span attr2="YY"> Dw </span></#{element}>
          <#{element} attr1=" AB BC "> E <span attr2="XX"> Fx </span></#{element}>
          <#{element} attr1=" ab bc "> G <span attr2="xx"> Hy </span></#{element}>
        </body>
      </html>
    \).xpath(path).map(&:text)
  end

  {
    # ///////////////////////////////////////////////////////////////////////////
    # {:include_inner_text => ...}
    # ///////////////////////////////////////////////////////////////////////////
    # >> text
    [{:text => 'A Bz'}, {:include_inner_text => true}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(.)="A Bz"]]|,
      expected_nodes = [' A  Bz ']
    ] },
    [{:text => 'A'}, {:include_inner_text => true}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(.)="A"]]|,
      expected_nodes = []
    ] },
    [{:text => 'A'}, {:include_inner_text => false}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(text())="A"]]|,
      expected_nodes = [' A  Bz ']
    ] },
    [{:text => 'A Bz'}, {:include_inner_text => false}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(text())="A Bz"]]|,
      expected_nodes = []
    ] },

    # ///////////////////////////////////////////////////////////////////////////
    # {:axis => ...}
    # ///////////////////////////////////////////////////////////////////////////
    # >> text
    [{:text => 'A Bz'}, {:axis => :self}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(.)="A Bz"]]|,
      expected_nodes = [' A  Bz ']
    ] },
    [{:text => 'Bz'}, {:axis => :descendant}] => lambda{|e| [
      expected_path  = %|//#{e}[./descendant::*[normalize-space(.)="Bz"]]|,
      expected_nodes = [' A  Bz ']
    ] },
    [{:text => 'A Bz'}, {:axis => :ancestor}] => lambda{|e| [
      expected_path  = %|//#{e}[./ancestor::*[normalize-space(.)="A Bz"]]|,
      expected_nodes = []
    ] },
    # >> attr
    [{:attr1 => 'AB BC'}, {:axis => :self}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="AB BC"]]|,
      expected_nodes = [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr2 => 'XX'}, {:axis => :descendant}] => lambda{|e| [
      expected_path  = %|//#{e}[./descendant::*[normalize-space(@attr2)="XX"]]|,
      expected_nodes = [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr2 => 'XX'}, {:axis => :ancestor}] => lambda{|e| [
      expected_path  = %|//#{e}[./ancestor::*[normalize-space(@attr2)="XX"]]|,
      expected_nodes = []
    ] },

    # ///////////////////////////////////////////////////////////////////////////
    # {:scope => ...}
    # ///////////////////////////////////////////////////////////////////////////
    # >> text
    [{:text => 'A Bz'}, {:scope => '//'}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(.)="A Bz"]]|,
      expected_nodes = [' A  Bz ']
    ] },
    [{:text => 'A Bz'}, {:scope => '//body/'}] => lambda{|e| [
      expected_path  = %|//body/#{e}[./self::*[normalize-space(.)="A Bz"]]|,
      expected_nodes = [' A  Bz ']
    ] },
    [{:text => 'A Bz'}, {:scope => '//boo/'}] => lambda{|e| [
      expected_path  = %|//boo/#{e}[./self::*[normalize-space(.)="A Bz"]]|,
      expected_nodes = []
    ] },
    # >> attr
    [{:attr1 => 'AB BC'}, {:scope => '//'}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="AB BC"]]|,
      expected_nodes = [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr1 => 'AB BC'}, {:scope => '//body/'}] => lambda{|e| [
      expected_path  = %|//body/#{e}[./self::*[normalize-space(@attr1)="AB BC"]]|,
      expected_nodes = [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr1 => 'AB BC'}, {:scope => '//boo/'}] => lambda{|e| [
      expected_path  = %|//boo/#{e}[./self::*[normalize-space(@attr1)="AB BC"]]|,
      expected_nodes = []
    ] },

    # ///////////////////////////////////////////////////////////////////////////
    # {:position => ...}
    # ///////////////////////////////////////////////////////////////////////////
    # >> text
    [{:text => 'A Bz'}, {:position => nil}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(.)="A Bz"]]|,
      expected_nodes = [' A  Bz ']
    ] },
    [{:text => 'A Bz'}, {:position => 2}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(.)="A Bz"][2]][2]|,
      expected_nodes = []
    ] },
    [{:text => 'A Bz'}, {:position => '2$'}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(.)="A Bz"][2]][2]|,
      expected_nodes = []
    ] },
    [{:text => 'A Bz'}, {:position => '^2'}] => lambda{|e| [
      expected_path  = %|//#{e}[2][./self::*[2][normalize-space(.)="A Bz"]]|,
      expected_nodes = []
    ] },
    # >> attr
    [{:attr1 => 'AB BC'}, {:position => nil}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="AB BC"]]|,
      expected_nodes = [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr1 => 'AB BC'}, {:position => 2}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="AB BC"][2]][2]|,
      expected_nodes = []
    ] },
    [{:attr1 => 'AB BC'}, {:position => '2$'}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="AB BC"][2]][2]|,
      expected_nodes = []
    ] },
    [{:attr1 => 'AB BC'}, {:position => '^2'}] => lambda{|e| [
      expected_path  = %|//#{e}[2][./self::*[2][normalize-space(@attr1)="AB BC"]]|,
      expected_nodes = []
    ] },

    # ///////////////////////////////////////////////////////////////////////////
    # {:normalize_space => ...}
    # ///////////////////////////////////////////////////////////////////////////
    # >> text
    [{:text => 'A Bz'}, {:normalize_space => true}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(.)="A Bz"]]|,
      expected_nodes = [' A  Bz ']
    ] },
    [{:text => ' A  Bz '}, {:normalize_space => true}] => lambda{|e| [
      expected_path = %|//#{e}[./self::*[normalize-space(.)=" A  Bz "]]|,
      expected_nodes = []
    ] },
    [{:text => ' A  Bz '}, {:normalize_space => false}] => lambda{|e| [
      expected_path = %|//#{e}[./self::*[.=" A  Bz "]]|,
      expected_nodes = [' A  Bz ']
    ] },
    [{:text => 'A Bz'}, {:normalize_space => false}] => lambda{|e| [
      expected_path = %|//#{e}[./self::*[.="A Bz"]]|,
      expected_nodes = []
    ] },
    # >> attr
    [{:attr1 => 'AB BC'}, {:normalize_space => true}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="AB BC"]]|,
      expected_nodes = [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr1 => ' AB BC '}, {:normalize_space => true}] => lambda{|e| [
      expected_path = %|//#{e}[./self::*[normalize-space(@attr1)=" AB BC "]]|,
      expected_nodes = []
    ] },
    [{:attr1 => ' AB BC '}, {:normalize_space => false}] => lambda{|e| [
      expected_path = %|//#{e}[./self::*[@attr1=" AB BC "]]|,
      expected_nodes = [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr1 => 'AB BC'}, {:normalize_space => false}] => lambda{|e| [
      expected_path = %|//#{e}[./self::*[@attr1="AB BC"]]|,
      expected_nodes = []
    ] },

    # ///////////////////////////////////////////////////////////////////////////
    # {:case_sensitive => ...}
    # ///////////////////////////////////////////////////////////////////////////
    # >> text
    [{:text => 'A Bz'}, {:case_sensitive => true}] => lambda{|e| [
      expected_path = %|//#{e}[./self::*[normalize-space(.)="A Bz"]]|,
      expected_nodes = [' A  Bz ']
    ] },
    [{:text => 'a bZ'}, {:case_sensitive => true}] => lambda{|e| [
      expected_path = %|//#{e}[./self::*[normalize-space(.)="a bZ"]]|,
      expected_nodes = []
    ] },
    [{:text => 'a bZ'}, {:case_sensitive => false}] => lambda{|e| [
      expected_path = %|//#{e}[./self::*[%s="a bz"]]| % translate_casing("normalize-space(.)"),
      expected_nodes = [' A  Bz ']
    ] },
    # >> attr
    [{:attr1 => 'AB BC'}, {:case_sensitive => true}] => lambda{|e| [
      expected_path = %|//#{e}[./self::*[normalize-space(@attr1)="AB BC"]]|,
      expected_nodes = [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr1 => 'ab bc'}, {:case_sensitive => true}] => lambda{|e| [
      expected_path = %|//#{e}[./self::*[normalize-space(@attr1)="ab bc"]]|,
      expected_nodes = [' G  Hy ']
    ] },
    [{:attr1 => 'ab bc'}, {:case_sensitive => false}] => lambda{|e| [
      %|//#{e}[./self::*[%s="ab bc"]]| % translate_casing("normalize-space(@attr1)"),
      [' A  Bz ', ' E  Fx ', ' G  Hy ']
    ] },

    # ///////////////////////////////////////////////////////////////////////////
    # Tokens matching (w match attr as array) / {:case_sensitive => ...}
    # ///////////////////////////////////////////////////////////////////////////
    # >> text
    [{:text => %w{Bz}}, {:case_sensitive => true}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(.)", [%|"Bz"|], true),
      [' A  Bz ']
    ] },
    [{:text => %w{A Bz}}, {:case_sensitive => true}] => lambda{|e| [
      %|//#{e}[./self::*[%s]]| % check_tokens("normalize-space(.)", [%|"A"|, %|"Bz"|], true),
      [' A  Bz ']
    ] },
    [{:text => %w{a bZ}}, {:case_sensitive => true}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(.)", [%|"a"|, %|"bZ"|], true),
      []
    ] },
    [{:text => %w{a bZ}}, {:case_sensitive => false}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens(translate_casing("normalize-space(.)"), [%|"a"|, %|"bz"|], true),
      [' A  Bz ']
    ] },
    # >> attr
    [{:attr1 => %w{AB}}, {:case_sensitive => true}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(@attr1)", [%|"AB"|], true),
      [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr1 => %w{AB BC}}, {:case_sensitive => true}] => lambda{|e| [
      %|//#{e}[./self::*[%s]]| % check_tokens("normalize-space(@attr1)", [%|"AB"|, %|"BC"|], true),
      [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr1 => %w{ab bc}}, {:case_sensitive => true}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(@attr1)", [%|"ab"|, %|"bc"|], true),
      [' G  Hy ']
    ] },
    [{:attr1 => %w{AB BC}}, {:case_sensitive => false}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens(translate_casing("normalize-space(@attr1)"), [%|"ab"|, %|"bc"|], true),
      [' A  Bz ', ' E  Fx ', ' G  Hy ']
    ] },

    # ///////////////////////////////////////////////////////////////////////////
    # Tokens matching (w match attr as array) / {:match_ordering => ...}
    # ///////////////////////////////////////////////////////////////////////////
    # >> text
    [{:text => %w{A Bz}}, {:match_ordering => true}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(.)", [%|"A"|, %|"Bz"|], true),
      [' A  Bz ']
    ] },
    [{:text => %w{Bz A}}, {:match_ordering => true}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(.)", [%|"Bz"|, %|"A"|], true),
      []
    ] },
    [{:text => %w{Bz A}}, {:match_ordering => false}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(.)", [%|"Bz"|, %|"A"|], false),
      [' A  Bz ']
    ] },
    # >> attr
    [{:attr1 => %w{AB BC}}, {:match_ordering => true}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(@attr1)", [%|"AB"|, %|"BC"|], true),
      [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr1 => %w{BC AB}}, {:match_ordering => true}] => lambda{|e| [
      %|//#{e}[./self::*[%s]]| % check_tokens("normalize-space(@attr1)", [%|"BC"|, %|"AB"|], true),
      []
    ] },
    [{:attr1 => %w{BC AB}}, {:match_ordering => false}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(@attr1)", [%|"BC"|, %|"AB"|], false),
      [' A  Bz ', ' E  Fx ']
    ] },
  }.inject({}) do |memo, args|
    memo.merge([contents, ignored_config, alternative_config] + args[0] => args[1])
  end
end

def xpf_no_match_attrs_args
  contents = lambda do |element, path|
    Nokogiri::HTML(%\
      <html>
        <body>
          <#{element}>AB</#{element}>
          <#{element}>CD</#{element}>
        </body>
      </html>
    \).xpath(path).map(&:text)
  end

  ignored_config = {
    :case_sensitive     => [true, false],
    :match_ordering     => [true, false],
    :normalize_space    => [true, false],
    :include_inner_text => [true, false],
    :axis               => [:self, :descendant, :ancestor, :child, :parent],
    :attribute_matcher  => [XPF::Matchers::Attribute, Class.new{}], # no error thrown means OK
    :text_matcher       => [XPF::Matchers::Text, Class.new{}],      # no error thrown means OK
    :literal_matcher    => [XPF::Matchers::Literal, Class.new{}],   # no error thrown means OK
    :group_matcher      => [XPF::Matchers::Group, Class.new{}],     # no error thrown means OK
  }

  {
    {:scope => '//', :position => nil}       => lambda{|e| ["//#{e}", %w{AB CD}] },
    {:scope => '//body/', :position => nil}  => lambda{|e| ["//body/#{e}", %w{AB CD}] },
    {:scope => '//xoo/', :position => nil}   => lambda{|e| ["//xoo/#{e}", %w{}] },
    {:scope => '//', :position => 2}         => lambda{|e| ["//#{e}[2]", %w{CD}] },
    {:scope => '//', :position => '^2'}      => lambda{|e| ["//#{e}[2]", %w{CD}] },
    {:scope => '//', :position => '2$'}      => lambda{|e| ["//#{e}[2]", %w{CD}] },
    {:scope => '//body/', :position => 2}    => lambda{|e| ["//body/#{e}[2]", %w{CD}] },
    {:scope => '//body/', :position => '^2'} => lambda{|e| ["//body/#{e}[2]", %w{CD}] },
    {:scope => '//body/', :position => '2$'} => lambda{|e| ["//body/#{e}[2]", %w{CD}] },
    {:scope => '//xoo/', :position => 2}     => lambda{|e| ["//xoo/#{e}[2]", %w{}] },
  }.inject({}) do |memo, args|
    memo.merge([contents, ignored_config, args[0]] => args[1])
  end
end

def xpf_default_config
  {
    :case_sensitive     => true,
    :match_ordering     => true,
    :normalize_space    => true,
    :include_inner_text => true,
    :scope              => '//',
    :position           => nil,
    :axis               => :self,
    :attribute_matcher  => XPF::Matchers::Attribute,
    :text_matcher       => XPF::Matchers::Text,
    :literal_matcher    => XPF::Matchers::Literal,
    :group_matcher      => XPF::Matchers::Group,
  }
end
