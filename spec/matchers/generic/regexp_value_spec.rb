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

  # Really hate to repeatedly type this !!
  tt = translate_casing('.')

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
      expected = [%|contains(#{tt},"hello")|, %w{i1 i2}],
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
      expected = [%|starts-with(#{tt},"hello")|, %w{i1 i2}],
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
      expected = [%|contains(#{tt},"^hello")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /World$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Hello World</x><x id="i2">hello world</x><x id="i3">World Hello</x>',
      regexp = /World$/,
      expected = [%|substring(.,string-length(.)-4)="World"|, %w{i1}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /World$/i,
      expected = [%|substring(#{tt},string-length(.)-4)="world"|, %w{i1 i2}]
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
      expected = [%|contains(#{tt},"world$")|, %w{i1 i2}],
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
      expected = [%|#{tt}="hello"|, %w{i1 i2}],
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
      expected = [%|contains(#{tt},"^hello$")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /o{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Helloo World</x><x id="i2">World HELLOO</x><x id="i3">Hello</x>',
      regexp = /o{2}/,
      expected = [%|contains(.,"oo")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /o{2}/i,
      expected = [%|contains(#{tt},"oo")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^o{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">oo World</x><x id="i2">OO WORLD</x><x id="i3">Helloo</x>',
      regexp = /^o{2}/,
      expected = [%|starts-with(.,"oo")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^o{2}/i,
      expected = [%|starts-with(#{tt},"oo")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /o{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">helloo</x><x id="i2">HELLOOO</x><x id="i3">Helloo World</x>',
      regexp = /o{2}$/,
      expected = [%|substring(.,string-length(.)-1)="oo"|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /o{2}$/i,
      expected = [%|substring(#{tt},string-length(.)-1)="oo"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^o{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">oo</x><x id="i2">OO</x><x id="i3">ooo</x>',
      regexp = /^o{2}$/,
      expected = [%|.="oo"|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^o{2}$/i,
      expected = [%|#{tt}="oo"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /o{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Helloo World</x><x id="i2">Hellooo World</x><x id="i3">World HELLOO</x><x id="i4">Hello</x>',
      regexp = /o{2,3}/,
      expected = ['(%s or %s)' % %w{oo ooo}.map{|t| %|contains(.,"#{t}")| }, %w{i1 i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /o{2,3}/i,
      expected = ['(%s or %s)' % %w{oo ooo}.map{|t| %|contains(#{tt},"#{t}")| }, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^o{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">oo blah</x><x id="i2">ooo blah</x><x id="i3">OO BLAH</x><x id="i4">o blah</x>',
      regexp = /^o{2,3}/,
      expected = ['(%s or %s)' % %w{oo ooo}.map{|t| %|starts-with(.,"#{t}")| }, %w{i1 i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^o{2,3}/i,
      expected = ['(%s or %s)' % %w{oo ooo}.map{|t| %|starts-with(#{tt},"#{t}")| }, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /o{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hellooo</x><x id="i2">helloo</x><x id="i3">HELLOOO</x><x id="i3">Hello</x>',
      regexp = /o{2,3}$/,
      expected = ['(%s or %s)' % %w{oo ooo}.map{|t| %|substring(.,string-length(.)#{1-t.size})="#{t}"| }, %w{i1 i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /o{2,3}$/i,
      expected = ['(%s or %s)' % %w{oo ooo}.map{|t| %|substring(#{tt},string-length(.)#{1-t.size})="#{t}"| }, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^o{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">oo</x><x id="i2">ooo</x><x id="i3">OO</x><x id="i4">o</x>',
      regexp = /^o{2,3}$/,
      expected = [%|(.="oo" or .="ooo")|, %w{i1 i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^o{2,3}$/i,
      expected = [%|(#{tt}="oo" or #{tt}="ooo")|, %w{i1 i2 i3}],
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
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">.AB</x><x id="i2">.ab</x><x id="i3">.abc</x><x id="i4">.a</x><x id="i5">.12</x>',
      regexp = /[a-z]{2}/,
      expected = [%|contains(#{translate_chars_set['.','a'..'z']},"aa")|, %w{i2 i3}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]{2}/i,
      expected = [%|contains(#{itranslate_chars_set['.','a'..'z']},"AA")|, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">.AB</x><x id="i2">.ab</x><x id="i3">.abc</x><x id="i4">.a</x><x id="i5">.12</x>',
      regexp = /[a-z]{2,3}/,
      expected = ['(%s or %s)' % %w{aa aaa}.map{|t| %|contains(#{translate_chars_set['.','a'..'z']},"#{t}")| }, %w{i2 i3}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]{2,3}/i,
      expected = ['(%s or %s)' % %w{AA AAA}.map{|t| %|contains(#{itranslate_chars_set['.','a'..'z']},"#{t}")| }, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">AB.</x><x id="i2">ab.</x><x id="i3">abc.</x><x id="i4">a.</x><x id="i5">12.</x>',
      regexp = /^[a-z]{2}/,
      expected = [%|starts-with(#{translate_chars_set['.','a'..'z']},"aa")|, %w{i2 i3}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]{2}/i,
      expected = [%|starts-with(#{itranslate_chars_set['.','a'..'z']},"AA")|, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">AB.</x><x id="i2">ab.</x><x id="i3">abc.</x><x id="i4">a.</x><x id="i5">12.</x>',
      regexp = /^[a-z]{2,3}/,
      expected = ['(%s or %s)' % %w{aa aaa}.map{|t| %|starts-with(#{translate_chars_set['.','a'..'z']},"#{t}")| }, %w{i2 i3}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]{2,3}/i,
      expected = ['(%s or %s)' % %w{AA AAA}.map{|t| %|starts-with(#{itranslate_chars_set['.','a'..'z']},"#{t}")| }, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">.AB</x><x id="i2">.ab</x><x id="i3">.abc</x><x id="i4">.a</x><x id="i5">.12</x>',
      regexp = /[a-z]{2}$/,
      expected = [%|substring(#{translate_chars_set['.','a'..'z']},string-length(.)-1)="aa"|, %w{i2 i3}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]{2}$/i,
      expected = [%|substring(#{itranslate_chars_set['.','a'..'z']},string-length(.)-1)="AA"|, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">.AB</x><x id="i2">.ab</x><x id="i3">.abc</x><x id="i4">.a</x><x id="i5">.12</x>',
      regexp = /[a-z]{2,3}$/,
      expected = ['(%s or %s)' % %w{aa aaa}.map{|t| %|substring(#{translate_chars_set['.','a'..'z']},string-length(.)-#{t.size-1})="#{t}"| }, %w{i2 i3}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]{2,3}$/i,
      expected = ['(%s or %s)' % %w{AA AAA}.map{|t| %|substring(#{itranslate_chars_set['.','a'..'z']},string-length(.)-#{t.size-1})="#{t}"| }, %w{i1 i2 i3}]
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">AA</x><x id="i2">aa</x><x id="i3">aaa</x><x id="i4">a</x><x id="i5">12</x>',
      regexp = /^[a-z]{2}$/,
      expected = [%|#{translate_chars_set['.','a'..'z']}="aa"|, %w{i2}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]{2}$/i,
      expected = [%|#{itranslate_chars_set['.','a'..'z']}="AA"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">AA</x><x id="i2">aa</x><x id="i3">aaa</x><x id="i4">a</x><x id="i5">12</x>',
      regexp = /^[a-z]{2,3}$/,
      expected = ['(%s or %s)' % %w{aa aaa}.map{|t| %|#{translate_chars_set['.','a'..'z']}="#{t}"| }, %w{i2 i3}]
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]{2,3}$/i,
      expected = ['(%s or %s)' % %w{AA AAA}.map{|t| %|#{itranslate_chars_set['.','a'..'z']}="#{t}"| }, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /Hello{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Helloo World</x><x id="i2">World HELLOO</x><x id="i3">Hello</x>',
      regexp = /Hello{2}/,
      expected = [%|contains(.,"Hell") and starts-with(substring-after(.,"Hell"),"oo")|, %w{i1}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /Hello{2}/i,
      expected = [%|contains(#{tt},"hell") and starts-with(substring-after(#{tt},"hell"),"oo")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^h{2}ello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO World</x><x id="i2">hhello</x><x id="i3">hello</x>',
      regexp = /^h{2}ello/,
      expected = [%|starts-with(.,"hh") and starts-with(substring-after(.,"hh"),"ello")|, %w{i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^h{2}ello/i,
      expected = [%|starts-with(#{tt},"hh") and starts-with(substring-after(#{tt},"hh"),"ello")|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /h{2}ello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">WORLD HHELLO</x><x id="i2">world hhello</x><x id="i3">hello</x>',
      regexp = /h{2}ello$/,
      expected = [%|contains(.,"hh") and substring-after(.,"hh")="ello"|, %w{i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /h{2}ello$/i,
      expected = [%|contains(#{tt},"hh") and substring-after(#{tt},"hh")="ello"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^h{2}ello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO</x><x id="i2">hhello</x><x id="i3">hello</x>',
      regexp = /^h{2}ello$/,
      expected = [%|starts-with(.,"hh") and substring-after(.,"hh")="ello"|, %w{i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^h{2}ello$/i,
      expected = [%|starts-with(#{tt},"hh") and substring-after(#{tt},"hh")="ello"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /hello{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HELLOO</x><x id="i2">helloo</x><x id="i3">hello</x>',
      regexp = /hello{2}$/,
      expected = [%|contains(.,"hell") and substring-after(.,"hell")="oo"|, %w{i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /hello{2}$/i,
      expected = [%|contains(#{tt},"hell") and substring-after(#{tt},"hell")="oo"|, %w{i1 i2}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /Hello{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Helloo World</x><x id="i2">Hellooo World</x><x id="i3">World HELLOO</x><x id="i4">Hello</x>',
      regexp = /Hello{2,3}/,
      expected = ['contains(.,"Hell") and (%s or %s)' % %w{oo ooo}.map{|t| %|starts-with(substring-after(.,"Hell"),"#{t}")| }, %w{i1 i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /Hello{2,3}/i,
      expected = [%|contains(#{tt},"hell") and (%s or %s)| % %w{oo ooo}.map{|t| %|starts-with(substring-after(#{tt},"hell"),"#{t}")| }, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^h{2,3}ello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO World</x><x id="i2">hhhello</x><x id="i3">hhello</x><x id="i4">hello</x>',
      regexp = /^h{2,3}ello/,
      expected = ['(%s or %s)' % %w{hh hhh}.map{|t| %|(starts-with(.,"#{t}") and starts-with(substring-after(.,"#{t}"),"ello"))| }, %w{i2 i3}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^h{2,3}ello/i,
      expected = ['(%s or %s)' % %w{hh hhh}.map{|t| %|(starts-with(#{tt},"#{t}") and starts-with(substring-after(#{tt},"#{t}"),"ello"))| }, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /h{2,3}ello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">WORLD HHHELLO</x><x id="i2">world hhhello</x><x id="i3">world hhello</x><x id="i4">hello</x>',
      regexp = /h{2,3}ello$/,
      expected = ['(%s or %s)' % %w{hh hhh}.map{|t| %|(contains(.,"#{t}") and substring-after(.,"#{t}")="ello")| }, %w{i2 i3}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /h{2,3}ello$/i,
      expected = ['(%s or %s)' % %w{hh hhh}.map{|t| %|(contains(#{tt},"#{t}") and substring-after(#{tt},"#{t}")="ello")| }, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^h{2,3}ello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHHELLO</x><x id="i2">hhhello</x><x id="i3">hhello</x><x id="i4">hello</x>',
      regexp = /^h{2,3}ello$/,
      expected = ['(%s or %s)' % %w{hh hhh}.map{|t| %|(starts-with(.,"#{t}") and substring-after(.,"#{t}")="ello")| }, %w{i2 i3}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /^h{2,3}ello$/i,
      expected = ['(%s or %s)' % %w{hh hhh}.map{|t| %|(starts-with(#{tt},"#{t}") and substring-after(#{tt},"#{t}")="ello")| }, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /hello{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HELLOO</x><x id="i2">helloo</x><x id="i3">hellooo</x><x id="i4">hello</x>',
      regexp = /hello{2,3}$/,
      expected = [%|contains(.,"hell") and (%s or %s)| % %w{oo ooo}.map{|t| %|substring-after(.,"hell")="#{t}"| }, %w{i2 i3}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /hello{2,3}$/i,
      expected = [%|contains(#{tt},"hell") and (%s or %s)| % %w{oo ooo}.map{|t| %|substring-after(#{tt},"hell")="#{t}"| }, %w{i1 i2 i3}],
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /Hell[o-s]{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Helloo World</x><x id="i2">Hellss World</x><x id="i3">World HELLOO</x><x id="i3">Hello</x>',
      regexp = /Hell[o-s]{2}/,
      expected = [%|contains(.,"Hell") and starts-with(#{translate_chars_set[%|substring-after(.,"Hell")|,'o'..'s']},"oo")|, %w{i1 i2}],
    ], [
      debug = __LINE__,
      xml,
      regexp = /Hell[o-s]{2}/i,
      expected = [%|contains(#{tt},"hell") and starts-with(#{itranslate_chars_set[%|substring-after(#{tt},"hell")|,'o'..'s']},"OO")|, %w{i1 i2 i3}],
#    ], [
#    # //////////////////////////////////////////////////////////////////////////////////////
#    # >> /^h{2}ello/
#    # //////////////////////////////////////////////////////////////////////////////////////
#      debug = __LINE__,
#      xml = '<x id="i1">HHELLO World</x><x id="i2">hhello</x><x id="i3">hello</x>',
#      regexp = /^h{2}ello/,
#      expected = [%|starts-with(.,"hh") and starts-with(substring-after(.,"hh"),"ello")|, %w{i2}],
#    ], [
#      debug = __LINE__,
#      xml,
#      regexp = /^h{2}ello/i,
#      expected = [%|starts-with(#{tt},"hh") and starts-with(substring-after(#{tt},"hh"),"ello")|, %w{i1 i2}],
#    ], [
#    # //////////////////////////////////////////////////////////////////////////////////////
#    # >> /h{2}ello$/
#    # //////////////////////////////////////////////////////////////////////////////////////
#      debug = __LINE__,
#      xml = '<x id="i1">WORLD HHELLO</x><x id="i2">world hhello</x><x id="i3">hello</x>',
#      regexp = /h{2}ello$/,
#      expected = [%|contains(.,"hh") and substring-after(.,"hh")="ello"|, %w{i2}],
#    ], [
#      debug = __LINE__,
#      xml,
#      regexp = /h{2}ello$/i,
#      expected = [%|contains(#{tt},"hh") and substring-after(#{tt},"hh")="ello"|, %w{i1 i2}],
#    ], [
#    # //////////////////////////////////////////////////////////////////////////////////////
#    # >> /^h{2}ello$/
#    # //////////////////////////////////////////////////////////////////////////////////////
#      debug = __LINE__,
#      xml = '<x id="i1">HHELLO</x><x id="i2">hhello</x><x id="i3">hello</x>',
#      regexp = /^h{2}ello$/,
#      expected = [%|starts-with(.,"hh") and substring-after(.,"hh")="ello"|, %w{i2}],
#    ], [
#      debug = __LINE__,
#      xml,
#      regexp = /^h{2}ello$/i,
#      expected = [%|starts-with(#{tt},"hh") and substring-after(#{tt},"hh")="ello"|, %w{i1 i2}],
#    ], [
#    # //////////////////////////////////////////////////////////////////////////////////////
#    # >> /hello{2}$/
#    # //////////////////////////////////////////////////////////////////////////////////////
#      debug = __LINE__,
#      xml = '<x id="i1">HELLOO</x><x id="i2">helloo</x><x id="i3">hello</x>',
#      regexp = /hello{2}$/,
#      expected = [%|contains(.,"hell") and substring-after(.,"hell")="oo"|, %w{i2}],
#    ], [
#      debug = __LINE__,
#      xml,
#      regexp = /hello{2}$/i,
#      expected = [%|contains(#{tt},"hell") and substring-after(#{tt},"hell")="oo"|, %w{i1 i2}],
#    ], [
#    # //////////////////////////////////////////////////////////////////////////////////////
#    # >> /Hello{2,3}/
#    # //////////////////////////////////////////////////////////////////////////////////////
#      debug = __LINE__,
#      xml = '<x id="i1">Helloo World</x><x id="i2">Hellooo World</x><x id="i3">World HELLOO</x><x id="i4">Hello</x>',
#      regexp = /Hello{2,3}/,
#      expected = ['contains(.,"Hell") and (%s or %s)' % %w{oo ooo}.map{|t| %|starts-with(substring-after(.,"Hell"),"#{t}")| }, %w{i1 i2}],
#    ], [
#      debug = __LINE__,
#      xml,
#      regexp = /Hello{2,3}/i,
#      expected = [%|contains(#{tt},"hell") and (%s or %s)| % %w{oo ooo}.map{|t| %|starts-with(substring-after(#{tt},"hell"),"#{t}")| }, %w{i1 i2 i3}],
#    ], [
#    # //////////////////////////////////////////////////////////////////////////////////////
#    # >> /^h{2,3}ello/
#    # //////////////////////////////////////////////////////////////////////////////////////
#      debug = __LINE__,
#      xml = '<x id="i1">HHELLO World</x><x id="i2">hhhello</x><x id="i3">hhello</x><x id="i4">hello</x>',
#      regexp = /^h{2,3}ello/,
#      expected = ['(%s or %s)' % %w{hh hhh}.map{|t| %|(starts-with(.,"#{t}") and starts-with(substring-after(.,"#{t}"),"ello"))| }, %w{i2 i3}],
#    ], [
#      debug = __LINE__,
#      xml,
#      regexp = /^h{2,3}ello/i,
#      expected = ['(%s or %s)' % %w{hh hhh}.map{|t| %|(starts-with(#{tt},"#{t}") and starts-with(substring-after(#{tt},"#{t}"),"ello"))| }, %w{i1 i2 i3}],
#    ], [
#    # //////////////////////////////////////////////////////////////////////////////////////
#    # >> /h{2,3}ello$/
#    # //////////////////////////////////////////////////////////////////////////////////////
#      debug = __LINE__,
#      xml = '<x id="i1">WORLD HHHELLO</x><x id="i2">world hhhello</x><x id="i3">world hhello</x><x id="i4">hello</x>',
#      regexp = /h{2,3}ello$/,
#      expected = ['(%s or %s)' % %w{hh hhh}.map{|t| %|(contains(.,"#{t}") and substring-after(.,"#{t}")="ello")| }, %w{i2 i3}],
#    ], [
#      debug = __LINE__,
#      xml,
#      regexp = /h{2,3}ello$/i,
#      expected = ['(%s or %s)' % %w{hh hhh}.map{|t| %|(contains(#{tt},"#{t}") and substring-after(#{tt},"#{t}")="ello")| }, %w{i1 i2 i3}],
#    ], [
#    # //////////////////////////////////////////////////////////////////////////////////////
#    # >> /^h{2,3}ello$/
#    # //////////////////////////////////////////////////////////////////////////////////////
#      debug = __LINE__,
#      xml = '<x id="i1">HHHELLO</x><x id="i2">hhhello</x><x id="i3">hhello</x><x id="i4">hello</x>',
#      regexp = /^h{2,3}ello$/,
#      expected = ['(%s or %s)' % %w{hh hhh}.map{|t| %|(starts-with(.,"#{t}") and substring-after(.,"#{t}")="ello")| }, %w{i2 i3}],
#    ], [
#      debug = __LINE__,
#      xml,
#      regexp = /^h{2,3}ello$/i,
#      expected = ['(%s or %s)' % %w{hh hhh}.map{|t| %|(starts-with(#{tt},"#{t}") and substring-after(#{tt},"#{t}")="ello")| }, %w{i1 i2 i3}],
#    ], [
#    # //////////////////////////////////////////////////////////////////////////////////////
#    # >> /hello{2,3}$/
#    # //////////////////////////////////////////////////////////////////////////////////////
#      debug = __LINE__,
#      xml = '<x id="i1">HELLOO</x><x id="i2">helloo</x><x id="i3">hellooo</x><x id="i4">hello</x>',
#      regexp = /hello{2,3}$/,
#      expected = [%|contains(.,"hell") and (%s or %s)| % %w{oo ooo}.map{|t| %|substring-after(.,"hell")="#{t}"| }, %w{i2 i3}],
#    ], [
#      debug = __LINE__,
#      xml,
#      regexp = /hello{2,3}$/i,
#      expected = [%|contains(#{tt},"hell") and (%s or %s)| % %w{oo ooo}.map{|t| %|substring-after(#{tt},"hell")="#{t}"| }, %w{i1 i2 i3}],
    ]
  ].each do |(debug, xml, regexp, (expected_condition, expected_ids))|
    #next unless debug == 514
    should 'return expr reflecting "%s" [#%s]' % [regexp, debug] do
      condition_should_equal[regexp, expected_condition]
      matched_element_ids_should_equal[xml, expected_condition, expected_ids]
    end
  end

end
