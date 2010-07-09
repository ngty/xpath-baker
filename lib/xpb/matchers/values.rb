module XPB
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

require 'xpb/matchers/values/reginald'
require 'xpb/matchers/values/string'
require 'xpb/matchers/values/unsorted_array'
require 'xpb/matchers/values/sorted_array'
require 'xpb/matchers/values/regexp'
