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

  expand_chars_set = lambda do |from|
    case from
    when Array
      from.map{|atom| atom.is_a?(Range) ? atom.to_a.join('') : atom }.join('')
    when Range
      from.to_a.join('')
    else
      from
    end
  end

  itranslate_chars_set = lambda do |expr, from|
    from = expand_chars_set[from]
    from = (from.upcase + from.downcase).split('').uniq.sort.join('')
    to = from[0..0] * from.size
    %|translate(#{expr},"#{from}","#{to}")|
  end

  translate_chars_set = lambda do |expr, from|
    from = expand_chars_set[from].split('').uniq.sort.join('')
    to = from[0..0] * from.size
    %|translate(#{expr},"#{from}","#{to}")|
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
      expected = [%|contains(#{translate_chars_set['.','a'..'z']},"a")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]/i,
      expected = [%|contains(#{itranslate_chars_set['.','a'..'z']},"A")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /^[a-z]/,
      expected = [%|starts-with(#{translate_chars_set['.','a'..'z']},"a")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]/i,
      expected = [%|starts-with(#{itranslate_chars_set['.','a'..'z']},"A")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /[a-z]$/,
      # WIP
      expected = [%|substring(#{translate_chars_set['.','a'..'z']},string-length(.))="a"|, %w{i1}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]$/i,
      expected = [%|substring(#{itranslate_chars_set['.','a'..'z']},string-length(.))="A"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">h</x><x id="i2">H</x><x id="i3">1</x>',
      regexp = /^[a-z]$/,
      # WIP
      expected = [%|#{translate_chars_set['.','a'..'z']}="a"|, %w{i1}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]$/i,
      expected = [%|#{itranslate_chars_set['.','a'..'z']}="A"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[A-Z]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /[A-Z]/,
      expected = [%|contains(#{translate_chars_set['.','A'..'Z']},"A")|, %w{i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /[A-Z]/i,
      expected = [%|contains(#{itranslate_chars_set['.','A'..'Z']},"A")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[^A-Z]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /^[A-Z]/,
      expected = [%|starts-with(#{translate_chars_set['.','A'..'Z']},"A")|, %w{i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[A-Z]/i,
      expected = [%|starts-with(#{itranslate_chars_set['.','A'..'Z']},"A")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[A-Z]$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /[A-Z]$/,
      # WIP
      expected = [%|substring(#{translate_chars_set['.','A'..'Z']},string-length(.))="A"|, %w{i2}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /[A-Z]$/i,
      expected = [%|substring(#{itranslate_chars_set['.','A'..'Z']},string-length(.))="A"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[A-Z]$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">h</x><x id="i2">H</x><x id="i3">1</x>',
      regexp = /^[A-Z]$/,
      # WIP
      expected = [%|#{translate_chars_set['.','A'..'Z']}="A"|, %w{i2}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[A-Z]$/i,
      expected = [%|#{itranslate_chars_set['.','A'..'Z']}="A"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[0-9]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">123</x><x id="i2">456</x><x id="i3">hello</x>',
      regexp = /[0-9]/,
      expected = [%|contains(#{translate_chars_set['.',0..9]},"0")|, %w{i1 i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /[0-9]/i,
      expected = [%|contains(#{translate_chars_set['.',0..9]},"0")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[b-d1-3]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">100</x><x id="i2">B44</x><x id="i3">ae45</x>',
      regexp = /[b-d1-3]/,
      expected = [%|contains(#{translate_chars_set['.',[1..3,'b'..'d']]},"1")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /[b-d1-3]/i,
      expected = [%|contains(#{itranslate_chars_set['.',[1..3,'b'..'d']]},"1")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[b-d1-3c-d]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">100</x><x id="i2">B44</x><x id="i3">ae45</x>',
      regexp = /[b-d1-3c-d]/,
      expected = [%|contains(#{translate_chars_set['.',[1..3,'b'..'d']]},"1")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /[b-d1-3c-d]/i,
      expected = [%|contains(#{itranslate_chars_set['.',[1..3,'b'..'d']]},"1")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[b-d1-3_\-]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">0_00</x><x id="i2">A-44</x><x id="i3">ae45</x>',
      regexp = /[b-d1-3_\-]/,
      expected = [%|contains(#{translate_chars_set['.',[1..3,'b'..'d','-_']]},"-")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[b-d1-3c-d]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">100</x><x id="i2">B44</x><x id="i3">ae45</x>',
      regexp = /[b-d1-3c-d]/,
      expected = [%|contains(#{translate_chars_set['.',[1..3,'b'..'d']]},"1")|, %w{i1}],
    ]
  ].each do |(debug, xml, regexp, (expected_condition, expected_ids))|
    #next unless debug >= 236
    should 'return expr reflecting "%s" [#%s]' % [regexp, debug] do
      condition_should_equal[regexp, expected_condition]
      matched_element_ids_should_equal[xml, expected_condition, expected_ids]
    end
  end

end
