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
      expected = [%|contains(translate(.,"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ","aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),"a")|, %w{i1 i2}],
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
      expected = [%|contains(translate(.,"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ","aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),"a")|, %w{i1 i2}],
    ]
  ].each do |(debug, xml, regexp, (expected_condition, expected_ids))|
    #next unless debug >= 115
    should 'return expr reflecting "%s" [#%s]' % [regexp, debug] do
      condition_should_equal[regexp, expected_condition]
      matched_element_ids_should_equal[xml, expected_condition, expected_ids]
    end
  end

end
