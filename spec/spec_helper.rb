require 'rubygems'
require 'bacon'
require 'nokogiri'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'xpf'

def translate_casing(expr)
  uc, lc = [('A'..'Z'), ('a'..'z')].map {|r| r.to_a.join('') }
  %|translate(#{expr},"#{uc}","#{lc}")|
end

def each_xpf(&blk)
  [XPF, send(:xpf)].each {|r| yield(r) }
end

def check_tokens(expr, tokens, enforce_ordering=true)
  tokens.map do |token|
    '(%s)' % [
      %|%s=#{token}|,
      %|contains(%s,concat(" ",#{token}," "))|,
      %|starts-with(%s,concat(#{token}," "))|,
      %|substring(%s,string-length(%s)+1-string-length(concat(" ",#{token})))=concat(" ",#{token})|,
    ].join(' or ') % ([expr]*5)
  end.concat(
    !enforce_ordering ? [] : (
      prev = tokens[0]
      tokens[1..-1].map do |token|
        (prev, _ = token, 'contains(substring-after(%s,%s),concat(" ",%s))' % [expr, prev, token])[1]
      end
  )).join(' and ')
end

Bacon.summary_on_exit
