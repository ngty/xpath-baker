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
  expr.extend(XPF::Matchers::Enhancements::String).check_tokens(tokens, enforce_ordering)
end

Bacon.summary_on_exit
