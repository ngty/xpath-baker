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

  itranslate_chars_set = itcs = lambda do |expr, from|
    from = expand_chars_set[from]
    from = (from.upcase + from.downcase).split('').uniq.sort.join('')
    to = from[0..0] * from.size
    %|translate(#{expr},"#{from}","#{to}")|
  end

  translate_chars_set = tcs = lambda do |expr, from|
    from = expand_chars_set[from].split('').uniq.sort.join('')
    to = from[0..0] * from.size
    %|translate(#{expr},"#{from}","#{to}")|
  end

  extract_substring = ess = lambda do |*args|
    token = args.pop
    expr = args.shift
    texpr2 = args.size == 2 ? args[1] : (args[0] || expr)
    texpr1 = args.size == 2 ? args[0] : texpr2
    %|substring(#{texpr1},1+string-length(#{expr})-string-length(substring-after(#{texpr2},"#{token}")))|
  end

  # Really hate to repeatedly type this !!
  tt = translate_casing('.')
  tc = lambda{|expr| translate_casing(expr) }

  [[
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /Hello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Hello World</x><x id="i2">World HELLO</x><x id="i3">World</x>',
      regexp = /Hello/,
      expected_cond = %|contains(.,"Hello")|,
      expected_ids = %w{i1}
    ], [
      debug = __LINE__,
      xml,
      regexp = /Hello/i,
      expected_cond = %|contains(#{tt},"HELLO")|,
      expected_ids = %w{i1 i2}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^Hello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Hello World</x><x id="i2">hello world</x><x id="i3">World hello</x>',
      regexp = /^Hello/,
      expected_cond = %|starts-with(.,"Hello")|,
      expected_ids = %w{i1}
    ], [
      debug = __LINE__,
      xml,
      regexp = /^Hello/i,
      expected_cond = %|starts-with(#{tt},"HELLO")|,
      expected_ids = %w{i1 i2}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /\^Hello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">^Hello World</x><x id="i2">^hello world</x><x id="i3">Hello world</x>',
      regexp = /\^Hello/,
      expected_cond = %|contains(.,"^Hello")|,
      expected_ids = %w{i1}
    ], [
      debug = __LINE__,
      xml,
      regexp = /\^Hello/i,
      expected_cond = %|contains(#{tt},"^HELLO")|,
      expected_ids = %w{i1 i2}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /World$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Hello World</x><x id="i2">hello world</x><x id="i3">World Hello</x>',
      regexp = /World$/,
      expected_cond = %|substring(.,string-length(.)-4)="World"|,
      expected_ids = %w{i1}
    ], [
      debug = __LINE__,
      xml,
      regexp = /World$/i,
      expected_cond = %|substring(#{tt},string-length(.)-4)="WORLD"|,
      expected_ids = %w{i1 i2}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /World\$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Hello World$</x><x id="i2">hello world$</x><x id="i3">Hello World</x>',
      regexp = /World\$/,
      expected_cond = %|contains(.,"World$")|, %w{i1},
    ], [
      debug = __LINE__,
      xml,
      regexp = /World\$/i,
      expected_cond = %|contains(#{tt},"WORLD$")|,
      expected_ids = %w{i1 i2}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^Hello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Hello</x><x id="i2">hello</x><x id="i3">Hello World</x>',
      regexp = /^Hello$/,
      expected_cond = %|.="Hello"|,
      expected_ids = %w{i1}
    ], [
      debug = __LINE__,
      xml,
      regexp = /^Hello$/i,
      expected_cond = %|#{tt}="HELLO"|,
      expected_ids = %w{i1 i2}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /\^Hello\$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">^Hello$</x><x id="i2">^hello$</x><x id="i3">^Hello</x><x id="i4">Hello$</x>',
      regexp = /\^Hello\$/,
      expected_cond = %|contains(.,"^Hello$")|,
      expected_ids = %w{i1}
    ], [
      debug = __LINE__,
      xml,
      regexp = /\^Hello\$/i,
      expected_cond = %|contains(#{tt},"^HELLO$")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /o{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Helloo World</x><x id="i2">World HELLOO</x><x id="i3">Hello</x>',
      regexp = /o{2}/,
      expected_cond = %|contains(.,"oo")|,
      expected_ids = %w{i1},
    ], [
      debug = __LINE__,
      xml,
      regexp = /o{2}/i,
      expected_cond = %|contains(#{tt},"OO")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^o{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">oo World</x><x id="i2">OO WORLD</x><x id="i3">Helloo</x>',
      regexp = /^o{2}/,
      expected_cond = %|starts-with(.,"oo")|,
      expected_ids = %w{i1},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^o{2}/i,
      expected_cond = %|starts-with(#{tt},"OO")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /o{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">helloo</x><x id="i2">HELLOOO</x><x id="i3">Helloo World</x>',
      regexp = /o{2}$/,
      expected_cond = %|substring(.,string-length(.)-1)="oo"|,
      expected_ids = %w{i1},
    ], [
      debug = __LINE__,
      xml,
      regexp = /o{2}$/i,
      expected_cond = %|substring(#{tt},string-length(.)-1)="OO"|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^o{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">oo</x><x id="i2">OO</x><x id="i3">ooo</x>',
      regexp = /^o{2}$/,
      expected_cond = %|.="oo"|,
      expected_ids = %w{i1},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^o{2}$/i,
      expected_cond = %|#{tt}="OO"|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /o{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Helloo World</x><x id="i2">Hellooo World</x><x id="i3">World HELLOO</x><x id="i4">Hello</x>',
      regexp = /o{2,3}/,
      expected_cond = '(%s or %s)' % %w{oo ooo}.map{|t| %|contains(.,"#{t}")| },
      expected_ids = %w{i1 i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /o{2,3}/i,
      expected_cond = '(%s or %s)' % %w{OO OOO}.map{|t| %|contains(#{tt},"#{t}")| },
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^o{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">oo blah</x><x id="i2">ooo blah</x><x id="i3">OO BLAH</x><x id="i4">o blah</x>',
      regexp = /^o{2,3}/,
      expected_cond = '(%s or %s)' % %w{oo ooo}.map{|t| %|starts-with(.,"#{t}")| },
      expected_ids = %w{i1 i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^o{2,3}/i,
      expected_cond = '(%s or %s)' % %w{OO OOO}.map{|t| %|starts-with(#{tt},"#{t}")| },
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /o{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hellooo</x><x id="i2">helloo</x><x id="i3">HELLOOO</x><x id="i3">Hello</x>',
      regexp = /o{2,3}$/,
      expected_cond = '(%s or %s)' % %w{oo ooo}.map{|t| %|substring(.,string-length(.)#{1-t.size})="#{t}"| },
      expected_ids = %w{i1 i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /o{2,3}$/i,
      expected_cond = '(%s or %s)' % %w{OO OOO}.map{|t| %|substring(#{tt},string-length(.)#{1-t.size})="#{t}"| },
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^o{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">oo</x><x id="i2">ooo</x><x id="i3">OO</x><x id="i4">o</x>',
      regexp = /^o{2,3}$/,
      expected_cond = %|(.="oo" or .="ooo")|,
      expected_ids = %w{i1 i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^o{2,3}$/i,
      expected_cond = %|(#{tt}="OO" or #{tt}="OOO")|,
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /[a-z]/,
      expected_cond = %|contains(#{tcs['.','a'..'z']},"a")|,
      expected_ids = %w{i1},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]/i,
      expected_cond = %|contains(#{itcs['.','a'..'z']},"A")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /\d/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">1</x><x id="i2">0</x><x id="i3">a</x><x id="i4">A</x>',
      regexp = /\d/,
      expected_cond = %|contains(#{tcs['.','0'..'9']},"0")|,
      expected_ids = %w{i1 i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /\d/i,
      expected_cond = %|contains(#{itcs['.','0'..'9']},"0")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /\w/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">1</x><x id="i2">a</x><x id="i3">A</x><x id="i4">_</x><<x id="i5">-</x>',
      regexp = /\w/,
      expected_cond = %|contains(#{tcs['.',['0'..'9','a'..'z','A'..'Z','_']]},"0")|,
      expected_ids = %w{i1 i2 i3 i4},
    ], [
      debug = __LINE__,
      xml,
      regexp = /\w/i,
      expected_cond = %|contains(#{itcs['.',['0'..'9','a'..'z','A'..'Z','_']]},"0")|,
      expected_ids = %w{i1 i2 i3 i4},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /^[a-z]/,
      expected_cond = %|starts-with(#{tcs['.','a'..'z']},"a")|,
      expected_ids = %w{i1},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]/i,
      expected_cond = %|starts-with(#{itcs['.','a'..'z']},"A")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /[a-z]$/,
      expected_cond = %|substring(#{tcs['.','a'..'z']},string-length(.))="a"|,
      expected_ids = %w{i1},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]$/i,
      expected_cond = %|substring(#{itcs['.','a'..'z']},string-length(.))="A"|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">h</x><x id="i2">H</x><x id="i3">1</x>',
      regexp = /^[a-z]$/,
      expected_cond = %|#{tcs['.','a'..'z']}="a"|,
      expected_ids = %w{i1},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]$/i,
      expected_cond = %|#{itcs['.','a'..'z']}="A"|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[A-Z]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /[A-Z]/,
      expected_cond = %|contains(#{tcs['.','A'..'Z']},"A")|,
      expected_ids = %w{i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[A-Z]/i,
      expected_cond = %|contains(#{itcs['.','A'..'Z']},"A")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[^A-Z]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /^[A-Z]/,
      expected_cond = %|starts-with(#{tcs['.','A'..'Z']},"A")|,
      expected_ids = %w{i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[A-Z]/i,
      expected_cond = %|starts-with(#{itcs['.','A'..'Z']},"A")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[A-Z]$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">hello</x><x id="i2">HELLO</x><x id="i3">123</x>',
      regexp = /[A-Z]$/,
      expected_cond = %|substring(#{tcs['.','A'..'Z']},string-length(.))="A"|,
      expected_ids = %w{i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[A-Z]$/i,
      expected_cond = %|substring(#{itcs['.','A'..'Z']},string-length(.))="A"|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[A-Z]$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">h</x><x id="i2">H</x><x id="i3">1</x>',
      regexp = /^[A-Z]$/,
      expected_cond = %|#{tcs['.','A'..'Z']}="A"|,
      expected_ids = %w{i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[A-Z]$/i,
      expected_cond = %|#{itcs['.','A'..'Z']}="A"|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[0-9]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">123</x><x id="i2">456</x><x id="i3">hello</x>',
      regexp = /[0-9]/,
      expected_cond = %|contains(#{tcs['.',0..9]},"0")|,
      expected_ids = %w{i1 i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[0-9]/i,
      expected_cond = %|contains(#{tcs['.',0..9]},"0")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[b-d1-3]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">100</x><x id="i2">B44</x><x id="i3">ae45</x>',
      regexp = /[b-d1-3]/,
      expected_cond = %|contains(#{tcs['.',[1..3,'b'..'d']]},"1")|,
      expected_ids = %w{i1},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[b-d1-3]/i,
      expected_cond = %|contains(#{itcs['.',[1..3,'b'..'d']]},"1")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[b-d1-3c-d]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">100</x><x id="i2">B44</x><x id="i3">ae45</x>',
      regexp = /[b-d1-3c-d]/,
      expected_cond = %|contains(#{tcs['.',[1..3,'b'..'d']]},"1")|,
      expected_ids = %w{i1},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[b-d1-3c-d]/i,
      expected_cond = %|contains(#{itcs['.',[1..3,'b'..'d']]},"1")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[b-d1-3_\-]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">0_00</x><x id="i2">A-44</x><x id="i3">ae45</x>',
      regexp = /[b-d1-3_\-]/,
      expected_cond = %|contains(#{tcs['.',[1..3,'b'..'d','-_']]},"-")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[b-d1-3c-d]/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">100</x><x id="i2">B44</x><x id="i3">ae45</x>',
      regexp = /[b-d1-3c-d]/,
      expected_cond = %|contains(#{tcs['.',[1..3,'b'..'d']]},"1")|,
      expected_ids = %w{i1},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">.AB</x><x id="i2">.ab</x><x id="i3">.abc</x><x id="i4">.a</x><x id="i5">.12</x>',
      regexp = /[a-z]{2}/,
      expected_cond = %|contains(#{tcs['.','a'..'z']},"aa")|,
      expected_ids = %w{i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]{2}/i,
      expected_cond = %|contains(#{itcs['.','a'..'z']},"AA")|,
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">.AB</x><x id="i2">.ab</x><x id="i3">.abc</x><x id="i4">.a</x><x id="i5">.12</x>',
      regexp = /[a-z]{2,3}/,
      expected_cond = '(%s or %s)' % %w{aa aaa}.map{|t| %|contains(#{tcs['.','a'..'z']},"#{t}")| },
      expected_ids = %w{i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]{2,3}/i,
      expected_cond = '(%s or %s)' % %w{AA AAA}.map{|t| %|contains(#{itcs['.','a'..'z']},"#{t}")| },
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">AB.</x><x id="i2">ab.</x><x id="i3">abc.</x><x id="i4">a.</x><x id="i5">12.</x>',
      regexp = /^[a-z]{2}/,
      expected_cond = %|starts-with(#{tcs['.','a'..'z']},"aa")|,
      expected_ids = %w{i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]{2}/i,
      expected_cond = %|starts-with(#{itcs['.','a'..'z']},"AA")|,
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">AB.</x><x id="i2">ab.</x><x id="i3">abc.</x><x id="i4">a.</x><x id="i5">12.</x>',
      regexp = /^[a-z]{2,3}/,
      expected_cond = '(%s or %s)' % %w{aa aaa}.map{|t| %|starts-with(#{tcs['.','a'..'z']},"#{t}")| },
      expected_ids = %w{i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]{2,3}/i,
      expected_cond = '(%s or %s)' % %w{AA AAA}.map{|t| %|starts-with(#{itcs['.','a'..'z']},"#{t}")| },
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">.AB</x><x id="i2">.ab</x><x id="i3">.abc</x><x id="i4">.a</x><x id="i5">.12</x>',
      regexp = /[a-z]{2}$/,
      expected_cond = %|substring(#{tcs['.','a'..'z']},string-length(.)-1)="aa"|,
      expected_ids = %w{i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]{2}$/i,
      expected_cond = %|substring(#{itcs['.','a'..'z']},string-length(.)-1)="AA"|,
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[a-z]{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">.AB</x><x id="i2">.ab</x><x id="i3">.abc</x><x id="i4">.a</x><x id="i5">.12</x>',
      regexp = /[a-z]{2,3}$/,
      expected_cond = '(%s or %s)' % %w{aa aaa}.map{|t| %|substring(#{tcs['.','a'..'z']},string-length(.)-#{t.size-1})="#{t}"| },
      expected_ids = %w{i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[a-z]{2,3}$/i,
      expected_cond = '(%s or %s)' % %w{AA AAA}.map{|t| %|substring(#{itcs['.','a'..'z']},string-length(.)-#{t.size-1})="#{t}"| },
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">AA</x><x id="i2">aa</x><x id="i3">aaa</x><x id="i4">a</x><x id="i5">12</x>',
      regexp = /^[a-z]{2}$/,
      expected_cond = %|#{tcs['.','a'..'z']}="aa"|,
      expected_ids = %w{i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]{2}$/i,
      expected_cond = %|#{itcs['.','a'..'z']}="AA"|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[a-z]{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">AA</x><x id="i2">aa</x><x id="i3">aaa</x><x id="i4">a</x><x id="i5">12</x>',
      regexp = /^[a-z]{2,3}$/,
      expected_cond = '(%s or %s)' % %w{aa aaa}.map{|t| %|#{tcs['.','a'..'z']}="#{t}"| },
      expected_ids = %w{i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[a-z]{2,3}$/i,
      expected_cond = '(%s or %s)' % %w{AA AAA}.map{|t| %|#{itcs['.','a'..'z']}="#{t}"| },
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /Hello{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Helloo World</x><x id="i2">World HELLOO</x><x id="i3">Hello</x>',
      regexp = /Hello{2}/,
      expected_cond = %|contains(.,"Hell") and starts-with(#{ess['.','Hell']},"oo")|,
      expected_ids = %w{i1},
    ], [
      debug = __LINE__,
      xml,
      regexp = /Hello{2}/i,
      expected_cond = %|contains(#{tt},"HELL") and starts-with(#{ess['.',tt,'HELL']},"OO")|,
      expected_ids = %w{i1 i2},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^hello{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HELLOO WORLD</x><x id="i2">helloo world</x><x id="i3">hello world</x>',
      regexp = /^hello{2}/,
      expected_cond = %|starts-with(.,"hell") and starts-with(#{ess['.','hell']},"oo")|,
      expected_ids = %w{i2}
    ], [
      debug = __LINE__,
      xml,
      regexp = /^hello{2}/i,
      expected_cond = %|starts-with(#{tt},"HELL") and starts-with(#{ess['.',tt,'HELL']},"OO")|,
      expected_ids = %w{i1 i2}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /hello{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HELLOO</x><x id="i2">helloo</x><x id="i3">hello</x>',
      regexp = /hello{2}$/,
      expected_cond = %|contains(.,"hell") and #{ess['.','hell']}="oo"|,
      expected_ids = %w{i2}
    ], [
      debug = __LINE__,
      xml,
      regexp = /hello{2}$/i,
      expected_cond = %|contains(#{tt},"HELL") and #{ess['.',tt,'HELL']}="OO"|,
      expected_ids = %w{i1 i2}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^hello{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HELLOO</x><x id="i2">helloo</x><x id="i3">hello</x>',
      regexp = /^hello{2}$/,
      expected_cond = %|starts-with(.,"hell") and #{ess['.','hell']}="oo"|,
      expected_ids = %w{i2}
    ], [
      debug = __LINE__,
      xml,
      regexp = /^hello{2}$/i,
      expected_cond = %|starts-with(#{tt},"HELL") and #{ess['.',tt,'HELL']}="OO"|,
      expected_ids = %w{i1 i2}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^h{2}ello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO World</x><x id="i2">hhello</x><x id="i3">hello</x>',
      regexp = /^h{2}ello/,
      expected_cond = %|starts-with(.,"hh") and starts-with(#{ess['.','hh']},"ello")|,
      expected_ids = %w{i2}
    ], [
      debug = __LINE__,
      xml,
      regexp = /^h{2}ello/i,
      expected_cond = %|starts-with(#{tt},"HH") and starts-with(#{ess['.',tt,'HH']},"ELLO")|,
      expected_ids = %w{i1 i2}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /h{2}ello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">WORLD HHELLO</x><x id="i2">world hhello</x><x id="i3">hello</x>',
      regexp = /h{2}ello$/,
      expected_cond = %|contains(.,"hh") and #{ess['.','hh']}="ello"|,
      expected_ids = %w{i2}
    ], [
      debug = __LINE__,
      xml,
      regexp = /h{2}ello$/i,
      expected_cond = %|contains(#{tt},"HH") and #{ess['.',tt,'HH']}="ELLO"|,
      expected_ids = %w{i1 i2}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^h{2}ello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO</x><x id="i2">hhello</x><x id="i3">hello</x>',
      regexp = /^h{2}ello$/,
      expected_cond = %|starts-with(.,"hh") and #{ess['.','hh']}="ello"|,
      expected_ids = %w{i2}
    ], [
      debug = __LINE__,
      xml,
      regexp = /^h{2}ello$/i,
      expected_cond = %|starts-with(#{tt},"HH") and #{ess['.',tt,'HH']}="ELLO"|,
      expected_ids = %w{i1 i2}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^h{2,3}ello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO World</x><x id="i2">hhhello</x><x id="i3">hhello</x><x id="i4">hello</x>',
      regexp = /^h{2,3}ello/,
      expected_cond = '(%s or %s)' %
        %w{hh hhh}.map{|t| %|(starts-with(.,"#{t}") and starts-with(#{ess['.',t]},"ello"))| },
      expected_ids = %w{i2 i3}
    ], [
      debug = __LINE__,
      xml,
      regexp = /^h{2,3}ello/i,
      expected_cond = '(%s or %s)' %
        %w{HH HHH}.map{|t| %|(starts-with(#{tt},"#{t}") and starts-with(#{ess['.',tt,t]},"ELLO"))| },
      expected_ids = %w{i1 i2 i3}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /h{2,3}ello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">WORLD HHHELLO</x><x id="i2">world hhhello</x><x id="i3">world hhello</x><x id="i4">hello</x>',
      regexp = /h{2,3}ello$/,
      expected_cond = '(%s or %s)' %
        %w{hh hhh}.map{|t| %|(contains(.,"#{t}") and #{ess['.',t]}="ello")| },
      expected_ids = %w{i2 i3}
    ], [
      debug = __LINE__,
      xml,
      regexp = /h{2,3}ello$/i,
      expected_cond = '(%s or %s)' %
        %w{HH HHH}.map{|t| %|(contains(#{tt},"#{t}") and #{ess['.',tt,t]}="ELLO")| },
      expected_ids = %w{i1 i2 i3}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^h{2,3}ello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHHELLO</x><x id="i2">hhhello</x><x id="i3">hhello</x><x id="i4">hello</x>',
      regexp = /^h{2,3}ello$/,
      expected_cond = '(%s or %s)' %
        %w{hh hhh}.map{|t| %|(starts-with(.,"#{t}") and #{ess['.',t]}="ello")| },
      expected_ids = %w{i2 i3}
    ], [
      debug = __LINE__,
      xml,
      regexp = /^h{2,3}ello$/i,
      expected_cond = '(%s or %s)' %
        %w{HH HHH}.map{|t| %|(starts-with(#{tt},"#{t}") and #{ess['.',tt,t]}="ELLO")| },
      expected_ids = %w{i1 i2 i3}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /Hello{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Helloo World</x><x id="i2">Hellooo World</x><x id="i3">World HELLOO</x><x id="i4">Hello</x>',
      regexp = /Hello{2,3}/,
      expected_cond = 'contains(.,"Hell") and (%s or %s)' %
        %w{oo ooo}.map{|t| %|starts-with(#{ess['.','Hell']},"#{t}")| },
      expected_ids = %w{i1 i2}
    ], [
      debug = __LINE__,
      xml,
      regexp = /Hello{2,3}/i,
      expected_cond = %|contains(#{tt},"HELL") and (%s or %s)| %
        %w{OO OOO}.map{|t| %|starts-with(#{ess['.',tt,'HELL']},"#{t}")| },
      expected_ids = %w{i1 i2 i3}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^Hello{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Helloo World</x><x id="i2">Hellooo World</x><x id="i3">HELLOO WORLD</x><x id="i4">Hello</x>',
      regexp = /^Hello{2,3}/,
      expected_cond = 'starts-with(.,"Hell") and (%s or %s)' %
        %w{oo ooo}.map{|t| %|starts-with(#{ess['.','Hell']},"#{t}")| },
      expected_ids = %w{i1 i2}
    ], [
      debug = __LINE__,
      xml,
      regexp = /^Hello{2,3}/i,
      expected_cond = %|starts-with(#{tt},"HELL") and (%s or %s)| %
        %w{OO OOO}.map{|t| %|starts-with(#{ess['.',tt,'HELL']},"#{t}")| },
      expected_ids = %w{i1 i2 i3}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /hello{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HELLOO</x><x id="i2">helloo</x><x id="i3">hellooo</x><x id="i4">hello</x>',
      regexp = /hello{2,3}$/,
      expected_cond = %|contains(.,"hell") and (%s or %s)| %
        %w{oo ooo}.map{|t| %|#{ess['.','hell']}="#{t}"| },
      expected_ids = %w{i2 i3}
    ], [
      debug = __LINE__,
      xml,
      regexp = /hello{2,3}$/i,
      expected_cond = %|contains(#{tt},"HELL") and (%s or %s)| %
        %w{OO OOO}.map{|t| %|#{ess['.',tt,'HELL']}="#{t}"| },
      expected_ids = %w{i1 i2 i3}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^hello{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HELLOO</x><x id="i2">helloo</x><x id="i3">hellooo</x><x id="i4">hello</x>',
      regexp = /^hello{2,3}$/,
      expected_cond = %|starts-with(.,"hell") and (%s or %s)| %
        %w{oo ooo}.map{|t| %|#{ess['.','hell']}="#{t}"| },
      expected_ids = %w{i2 i3}
    ], [
      debug = __LINE__,
      xml,
      regexp = /^hello{2,3}$/i,
      expected_cond = %|starts-with(#{tt},"HELL") and (%s or %s)| %
        %w{OO OOO}.map{|t| %|#{ess['.',tt,'HELL']}="#{t}"| },
      expected_ids = %w{i1 i2 i3}
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /Hell[o-s]{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">Helloo World</x><x id="i2">Hellss World</x><x id="i3">World HELLOO</x><x id="i3">Hello</x>',
      regexp = /Hell[o-s]{2}/,
      expected_cond = %|contains(.,"Hell") and starts-with(#{tcs[ess['.','Hell'],'o'..'s']},"oo")|,
      expected_ids = %w{i1 i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /Hell[o-s]{2}/i,
      expected_cond = %|contains(#{tt},"HELL") and starts-with(#{itcs[ess['.','.',tt,'HELL'],'o'..'s']},"OO")|,
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^hell[o-s]{2}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">helloo world</x><x id="i2">hellss world</x><x id="i3">HELLOO WORLD</x><x id="i4">Hello</x>',
      regexp = /^hell[o-s]{2}/,
      expected_cond = %|starts-with(.,"hell") and starts-with(#{tcs[ess['.','hell'],'o'..'s']},"oo")|,
      expected_ids = %w{i1 i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^hell[o-s]{2}/i,
      expected_cond = %|starts-with(#{tt},"HELL") and starts-with(#{itcs[ess['.','.',tt,'HELL'],'o'..'s']},"OO")|,
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /hell[o-s]{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">world helloo</x><x id="i2">world hellss</x><x id="i3">World HELLOO</x><x id="i4">Hello</x>',
      regexp = /hell[o-s]{2}$/,
      expected_cond = %|contains(.,"hell") and #{tcs[ess['.','hell'],'o'..'s']}="oo"|,
      expected_ids = %w{i1 i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /hell[o-s]{2}$/i,
      expected_cond = %|contains(#{tt},"HELL") and #{itcs[ess['.','.',tt,'HELL'],'o'..'s']}="OO"|,
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^hell[o-s]{2}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">helloo</x><x id="i2">hellss</x><x id="i3">HELLOO</x><x id="i4">Hello</x>',
      regexp = /^hell[o-s]{2}$/,
      expected_cond = %|starts-with(.,"hell") and #{tcs[ess['.','hell'],'o'..'s']}="oo"|,
      expected_ids = %w{i1 i2},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^hell[o-s]{2}$/i,
      expected_cond = %|starts-with(#{tt},"HELL") and #{itcs[ess['.','.',tt,'HELL'],'o'..'s']}="OO"|,
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[h-j]{2}ello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO World</x><x id="i2">hhello</x><x id="i3">jjello</x><x id="i4">hello</x>',
      regexp = /[h-j]{2}ello/,
      expected_cond = %|contains(#{tcs['.','h'..'j']},"hh") and | +
        %|starts-with(#{ess['.','.',tcs['.','h'..'j'],'hh']},"ello")|,
      expected_ids = %w{i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[h-j]{2}ello/i,
      expected_cond = %|contains(#{itcs['.','h'..'j']},"HH") and | +
        %|starts-with(#{ess['.',tt,itcs['.','h'..'j'],'HH']},"ELLO")|,
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[h-j]{2}ello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO World</x><x id="i2">hhello</x><x id="i3">jjello</x><x id="i4">hello</x>',
      regexp = /^[h-j]{2}ello/,
      expected_cond = %|starts-with(#{tcs['.','h'..'j']},"hh") and | +
        %|starts-with(#{ess['.','.',tcs['.','h'..'j'],'hh']},"ello")|,
      expected_ids = %w{i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[h-j]{2}ello/i,
      expected_cond = %|starts-with(#{itcs['.','h'..'j']},"HH") and | +
        %|starts-with(#{ess['.',tt,itcs['.','h'..'j'],'HH']},"ELLO")|,
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[h-j]{2}ello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">World HHELLO</x><x id="i2">world hhello</x><x id="i3">world jjello</x><x id="i4">hello</x>',
      regexp = /[h-j]{2}ello$/,
      expected_cond = %|contains(#{tcs['.','h'..'j']},"hh") and #{ess['.','.',tcs['.','h'..'j'],'hh']}="ello"|,
      expected_ids = %w{i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[h-j]{2}ello$/i,
      expected_cond = %|contains(#{itcs['.','h'..'j']},"HH") and #{ess['.',tt,itcs['.','h'..'j'],'HH']}="ELLO"|,
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[h-j]{2}ello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO</x><x id="i2">hhello</x><x id="i3">jjello</x><x id="i4">hello</x>',
      regexp = /^[h-j]{2}ello$/,
      expected_cond = %|starts-with(#{tcs['.','h'..'j']},"hh") and #{ess['.','.',tcs['.','h'..'j'],'hh']}="ello"|,
      expected_ids = %w{i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[h-j]{2}ello$/i,
      expected_cond = %|starts-with(#{itcs['.','h'..'j']},"HH") and #{ess['.',tt,itcs['.','h'..'j'],'HH']}="ELLO"|,
      expected_ids = %w{i1 i2 i3},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /hell[o-s]{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">helloo</x><x id="i2">hellss</x><x id="i3">hellooo</x><x id="i4">HELLOO</x><x id="i5">hello</x>',
      regexp = /hell[o-s]{2,3}/,
      expected_cond = %|contains(.,"hell") and (%s or %s)| %
        %w{oo ooo}.map{|t| %|starts-with(#{tcs[ess['.','hell'],'o'..'s']},"#{t}")| },
      expected_ids = %w{i1 i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /hell[o-s]{2,3}/i,
      expected_cond = %|contains(#{tt},"HELL") and (%s or %s)| %
        %w{OO OOO}.map{|t| %|starts-with(#{itcs[ess['.','.',tt,'HELL'],'o'..'s']},"#{t}")| },
      expected_ids = %w{i1 i2 i3 i4},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^hell[o-s]{2,3}/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">helloo</x><x id="i2">hellss</x><x id="i3">hellooo</x><x id="i4">HELLOO</x><x id="i5">hello</x>',
      regexp = /^hell[o-s]{2,3}/,
      expected_cond = %|starts-with(.,"hell") and (%s or %s)| %
        %w{oo ooo}.map{|t| %|starts-with(#{tcs[ess['.','hell'],'o'..'s']},"#{t}")| },
      expected_ids = %w{i1 i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^hell[o-s]{2,3}/i,
      expected_cond = %|starts-with(#{tt},"HELL") and (%s or %s)| %
        %w{OO OOO}.map{|t| %|starts-with(#{itcs[ess['.','.',tt,'HELL'],'o'..'s']},"#{t}")| },
      expected_ids = %w{i1 i2 i3 i4},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /hell[o-s]{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">helloo</x><x id="i2">hellss</x><x id="i3">hellooo</x><x id="i4">HELLOO</x><x id="i5">hello</x>',
      regexp = /hell[o-s]{2,3}$/,
      expected_cond = %|contains(.,"hell") and (%s or %s)| %
        %w{oo ooo}.map{|t| %|#{tcs[ess['.','hell'],'o'..'s']}="#{t}"| },
      expected_ids = %w{i1 i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /hell[o-s]{2,3}$/i,
      expected_cond = %|contains(#{tt},"HELL") and (%s or %s)| %
        %w{OO OOO}.map{|t| %|#{itcs[ess['.','.',tt,'HELL'],'o'..'s']}="#{t}"| },
      expected_ids = %w{i1 i2 i3 i4},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^hell[o-s]{2,3}$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">helloo</x><x id="i2">hellss</x><x id="i3">hellooo</x><x id="i4">HELLOO</x><x id="i5">hello</x>',
      regexp = /^hell[o-s]{2,3}$/,
      expected_cond = %|starts-with(.,"hell") and (%s or %s)| %
        %w{oo ooo}.map{|t| %|#{tcs[ess['.','hell'],'o'..'s']}="#{t}"| },
      expected_ids = %w{i1 i2 i3},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^hell[o-s]{2,3}$/i,
      expected_cond = %|starts-with(#{tt},"HELL") and (%s or %s)| %
        %w{OO OOO}.map{|t| %|#{itcs[ess['.','.',tt,'HELL'],'o'..'s']}="#{t}"| },
      expected_ids = %w{i1 i2 i3 i4},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[h-j]{2}ello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO</x><x id="i2">hhello</x><x id="i3">jjello</x><x id="i4">hhhello</x><x id="i5">hello</x>',
      regexp = /[h-j]{2,3}ello/,
      expected_cond = '((%s) or (%s))' % %w{hh hhh}.
        map{|t| %|contains(#{tcs['.','h'..'j']},"#{t}") and starts-with(#{ess['.','.',tcs['.','h'..'j'],t]},"ello")| },
      expected_ids = %w{i2 i3 i4},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[h-j]{2,3}ello/i,
      expected_cond = '((%s) or (%s))' % %w{HH HHH}.
        map{|t| %|contains(#{itcs['.','h'..'j']},"#{t}") and starts-with(#{ess['.',tt,itcs['.','h'..'j'],t]},"ELLO")| },
      expected_ids = %w{i1 i2 i3 i4},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[h-j]{2,3}ello/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO</x><x id="i2">hhello</x><x id="i3">jjello</x><x id="i4">hhhello</x><x id="i5">hello</x>',
      regexp = /^[h-j]{2,3}ello/,
      expected_cond = '((%s) or (%s))' % %w{hh hhh}.
        map{|t| %|starts-with(#{tcs['.','h'..'j']},"#{t}") and starts-with(#{ess['.','.',tcs['.','h'..'j'],t]},"ello")| },
      expected_ids = %w{i2 i3 i4},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[h-j]{2,3}ello/i,
      expected_cond = '((%s) or (%s))' % %w{HH HHH}.
        map{|t| %|starts-with(#{itcs['.','h'..'j']},"#{t}") and starts-with(#{ess['.',tt,itcs['.','h'..'j'],t]},"ELLO")| },
      expected_ids = %w{i1 i2 i3 i4},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /[h-j]{2,3}ello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO</x><x id="i2">hhello</x><x id="i3">jjello</x><x id="i4">hhhello</x><x id="i5">hello</x>',
      regexp = /[h-j]{2,3}ello$/,
      expected_cond = '((%s) or (%s))' % %w{hh hhh}.
        map{|t| %|contains(#{tcs['.','h'..'j']},"#{t}") and #{ess['.','.',tcs['.','h'..'j'],t]}="ello"| },
      expected_ids = %w{i2 i3 i4},
    ], [
      debug = __LINE__,
      xml,
      regexp = /[h-j]{2,3}ello$/i,
      expected_cond = '((%s) or (%s))' % %w{HH HHH}.
        map{|t| %|contains(#{itcs['.','h'..'j']},"#{t}") and #{ess['.',tt,itcs['.','h'..'j'],t]}="ELLO"| },
      expected_ids = %w{i1 i2 i3 i4},
    ], [
    # //////////////////////////////////////////////////////////////////////////////////////
    # >> /^[h-j]{2,3}ello$/
    # //////////////////////////////////////////////////////////////////////////////////////
      debug = __LINE__,
      xml = '<x id="i1">HHELLO</x><x id="i2">hhello</x><x id="i3">jjello</x><x id="i4">hhhello</x><x id="i5">hello</x>',
      regexp = /^[h-j]{2,3}ello$/,
      expected_cond = '((%s) or (%s))' % %w{hh hhh}.
        map{|t| %|starts-with(#{tcs['.','h'..'j']},"#{t}") and #{ess['.','.',tcs['.','h'..'j'],t]}="ello"| },
      expected_ids = %w{i2 i3 i4},
    ], [
      debug = __LINE__,
      xml,
      regexp = /^[h-j]{2,3}ello$/i,
      expected_cond = '((%s) or (%s))' % %w{HH HHH}.
        map{|t| %|starts-with(#{itcs['.','h'..'j']},"#{t}") and #{ess['.',tt,itcs['.','h'..'j'],t]}="ELLO"| },
      expected_ids = %w{i1 i2 i3 i4},
    ]
  ].each do |(debug, xml, regexp, expected_cond, expected_ids)|
    #next unless debug == 773
    #next unless debug > 587
    #next unless [768,783].include?(debug)
    should 'return expr reflecting "%s" [#%s]' % [regexp, debug] do
      condition_should_equal[regexp, expected_cond]
      matched_element_ids_should_equal[xml, expected_cond, expected_ids]
    end
  end

end
