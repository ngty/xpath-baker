require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe 'XPF::Matchers regexp value matching' do

  convertor = Class.new do
    include XPF::Matchers::Matchable
    public :r
  end

  condition_should_equal = lambda do |regexp, expected|
    convertor.new.r('.', regexp).should.equal(expected)
  end

  matched_element_ids_should_equal = lambda do |xml, condition, expected|
    Nokogiri::XML('<root>%s</root>' % xml).xpath('//x[%s]' % condition).
      map{|node| node.attribute('id').to_s }.should.equal(expected)
  end

  [
    [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /Hello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Hello World</x><x id="i2">World HELLO</x><x id="i3">World</x>',
      regexp = /Hello/,
      expected = [%|contains(.,"Hello")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /Hello/i,
      expected = [%|contains(#{translate_casing('.')},"hello")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^Hello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Hello World</x><x id="i2">hello world</x><x id="i3">World hello</x>',
      regexp = /^Hello/,
      expected = [%|starts-with(.,"Hello")|, %w{i1}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /^Hello/i,
      expected = [%|starts-with(#{translate_casing('.')},"hello")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /\^Hello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">^Hello World</x><x id="i2">^hello world</x><x id="i3">Hello world</x>',
      regexp = /\^Hello/,
      expected = [%|contains(.,"^Hello")|, %w{i1}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /\^Hello/i,
      expected = [%|contains(#{translate_casing('.')},"^hello")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /World$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Hello World</x><x id="i2">hello world</x><x id="i3">World Hello</x>',
      regexp = /World$/,
      expected = [%|substring(.,string-length(.)+1-string-length("World"))="World"|, %w{i1}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /World$/i,
      expected = [%|substring(#{translate_casing('.')},string-length(.)+1-string-length("world"))="world"|, %w{i1 i2}]
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /World\$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Hello World$</x><x id="i2">hello world$</x><x id="i3">Hello World</x>',
      regexp = /World\$/,
      expected = [%|contains(.,"World$")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /World\$/i,
      expected = [%|contains(#{translate_casing('.')},"world$")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^Hello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Hello</x><x id="i2">hello</x><x id="i3">Hello World</x>',
      regexp = /^Hello$/,
      expected = [%|.="Hello"|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^Hello$/i,
      expected = [%|#{translate_casing('.')}="hello"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /\^Hello\$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">^Hello$</x><x id="i2">^hello$</x><x id="i3">^Hello</x><x id="i4">Hello$</x>',
      regexp = /\^Hello\$/,
      expected = [%|contains(.,"^Hello$")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /\^Hello\$/i,
      expected = [%|contains(#{translate_casing('.')},"^hello$")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /[a-z]/,
      expected = [%|contains(translate(.,"abcdefghijklmnopqrstuvwxyz","aaaaaaaaaaaaaaaaaaaaaaaaaa"),"a")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]/i,
      expected = [%|contains(translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz","AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),"A")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /^[a-z]/,
      expected = [%|starts-with(translate(.,"abcdefghijklmnopqrstuvwxyz","aaaaaaaaaaaaaaaaaaaaaaaaaa"),"a")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]/i,
      expected = [%|starts-with(translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz","AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),"A")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /[a-z]$/,
      # WIP
      expected = [%|substring(translate(.,"abcdefghijklmnopqrstuvwxyz","aaaaaaaaaaaaaaaaaaaaaaaaaa"),string-length(.))="a"|, %w{i1}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]$/i,
      expected = [%|substring(translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz","AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),string-length(.))="A"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">h</x><x id="i2">H</x><x id="i3">1</x>',
      regexp = /^[a-z]$/,
      # WIP
      expected = [%|translate(.,"abcdefghijklmnopqrstuvwxyz","aaaaaaaaaaaaaaaaaaaaaaaaaa")="a"|, %w{i1}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]$/i,
      expected = [%|translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz","AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")="A"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[A-Z]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /[A-Z]/,
      expected = [%|contains(translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","AAAAAAAAAAAAAAAAAAAAAAAAAA"),"A")|, %w{i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /[A-Z]/i,
      expected = [%|contains(translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz","AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),"A")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[^A-Z]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /^[A-Z]/,
      expected = [%|starts-with(translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","AAAAAAAAAAAAAAAAAAAAAAAAAA"),"A")|, %w{i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[A-Z]/i,
      expected = [%|starts-with(translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz","AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),"A")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[A-Z]$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /[A-Z]$/,
      # WIP
      expected = [%|substring(translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","AAAAAAAAAAAAAAAAAAAAAAAAAA"),string-length(.))="A"|, %w{i2}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /[A-Z]$/i,
      expected = [%|substring(translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz","AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),string-length(.))="A"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[A-Z]$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">h</x><x id="i2">H</x><x id="i3">1</x>',
      regexp = /^[A-Z]$/,
      # WIP
      expected = [%|translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","AAAAAAAAAAAAAAAAAAAAAAAAAA")="A"|, %w{i2}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[A-Z]$/i,
      expected = [%|translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz","AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")="A"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[0-9]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">123</x><x id="i2">456</x><x id="i3">hello</x>',
      regexp = /[0-9]/,
      expected = [%|contains(translate(.,"0123456789","0000000000"),"0")|, %w{i1 i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /[0-9]/i,
      expected = [%|contains(translate(.,"0123456789","0000000000"),"0")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[b-d1-3]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">100</x><x id="i2">B44</x><x id="i3">ae45</x>',
      regexp = /[b-d1-3]/,
      expected = [%|contains(translate(.,"123bcd","111111"),"1")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /[b-d1-3]/i,
      expected = [%|contains(translate(.,"123BCDbcd","111111111"),"1")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[b-d1-3c-d]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">100</x><x id="i2">B44</x><x id="i3">ae45</x>',
      regexp = /[b-d1-3c-d]/,
      expected = [%|contains(translate(.,"123bcd","111111"),"1")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /[b-d1-3c-d]/i,
      expected = [%|contains(translate(.,"123BCDbcd","111111111"),"1")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[b-d1-3_\-]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">0_00</x><x id="i2">A-44</x><x id="i3">ae45</x>',
      regexp = /[b-d1-3_\-]/,
      expected = [%|contains(translate(.,"-123_bcd","--------"),"-")|, %w{i1 i2}],
#    ], [
#      debug = __LINE__,
#      xml,
#      regexp = /[b-d1-3c-d]/i,
#      expected = [%|contains(translate(.,"bcdBCD123","bbbbbbbbb"),"b")|, %w{i1 i2}],
    ]
  ].each do |(debug, xml, regexp, (expected_condition, expected_ids))|
    #next unless debug >= 236
    should 'return expr reflecting "%s" [#%s]' % [regexp, debug] do
      condition_should_equal[regexp, expected_condition]
      matched_element_ids_should_equal[xml, expected_condition, expected_ids]
    end
  end

end
