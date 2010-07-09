module XPathBaker
  module Matchers
    module Values
      class << self
        def Value(*attrs) #:nodoc:
          Struct.new(*attrs)
        end
      end
    end
  end
end

require 'xpath-baker/matchers/values/reginald'
require 'xpath-baker/matchers/values/string'
require 'xpath-baker/matchers/values/unsorted_array'
require 'xpath-baker/matchers/values/sorted_array'
require 'xpath-baker/matchers/values/regexp'
