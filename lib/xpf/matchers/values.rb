module XPF
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

require 'xpf/matchers/values/string'
require 'xpf/matchers/values/unsorted_array'
require 'xpf/matchers/values/sorted_array'
require 'xpf/matchers/values/regexp'
