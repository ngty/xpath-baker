require 'rubygems'
require 'bacon'
require 'nokogiri'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'xpathfu'

Bacon.summary_on_exit
