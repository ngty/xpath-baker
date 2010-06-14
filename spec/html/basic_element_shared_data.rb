def xpf_match_attrs_args
  ignored_config_settings = {:match_ordering => [true, false]}
  contents = lambda do |element, path|
    Nokogiri::HTML(%\
      <html>
        <body>
          <#{element} attr1=" AB BC "> A <span attr2="XX"> Bz </span></#{element}>
          <#{element} attr1=" CD DE "> C <span attr2="YY"> D </span></#{element}>
          <#{element} attr1=" AB BC "> E <span attr2="XX"> Fx </span></#{element}>
          <#{element} attr1=" ab bc "> G <span attr2="xx"> Hy </span></#{element}>
        </body>
      </html>
    \).xpath(path).map(&:text)
  end

  {
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
    [{:attr1 => 'AB BC'}, {:axis => :self}] => lambda{|e| [
      expected_path  = %|//#{e}[./self::*[normalize-space(@attr1)="AB BC"]]|,
      expected_nodes = [' A  Bz ', ' E  Fx ']
    ] },
    # >> attr
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
    # Tokens matching (w match attr as array)
    # ///////////////////////////////////////////////////////////////////////////
    # >> text
    [{:text => %w{Bz}}, {:case_sensitive => true}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(.)", [%|"Bz"|]),
      [' A  Bz ']
    ] },
    [{:text => %w{A Bz}}, {:case_sensitive => true}] => lambda{|e| [
      %|//#{e}[./self::*[%s]]| % check_tokens("normalize-space(.)", [%|"A"|, %|"Bz"|]),
      [' A  Bz ']
    ] },
    [{:text => %w{a bZ}}, {:case_sensitive => true}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(.)", [%|"a"|, %|"bZ"|]),
      []
    ] },
    [{:text => %w{a bZ}}, {:case_sensitive => false}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens(translate_casing("normalize-space(.)"), [%|"a"|, %|"bz"|]),
      [' A  Bz ']
    ] },
    # >> attr
    [{:attr1 => %w{AB}}, {:case_sensitive => true}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(@attr1)", [%|"AB"|]),
      [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr1 => %w{AB BC}}, {:case_sensitive => true}] => lambda{|e| [
      %|//#{e}[./self::*[%s]]| % check_tokens("normalize-space(@attr1)", [%|"AB"|, %|"BC"|]),
      [' A  Bz ', ' E  Fx ']
    ] },
    [{:attr1 => %w{ab bc}}, {:case_sensitive => true}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens("normalize-space(@attr1)", [%|"ab"|, %|"bc"|]),
      [' G  Hy ']
    ] },
    [{:attr1 => %w{AB BC}}, {:case_sensitive => false}] => lambda{|e| [
      "//#{e}[./self::*[%s]]" % check_tokens(translate_casing("normalize-space(@attr1)"), [%|"ab"|, %|"bc"|]),
      [' A  Bz ', ' E  Fx ', ' G  Hy ']
    ] },
  }.inject({}) do |memo, args|
    memo.merge([contents, ignored_config_settings] + args[0] => args[1])
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

  ignored_config_settings = {
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
    memo.merge([contents, ignored_config_settings, args[0]] => args[1])
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
