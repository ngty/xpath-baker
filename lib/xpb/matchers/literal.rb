module XPB
  module Matchers
    class Literal < Matcher(:value, :config)
      def condition
        value
      end
    end
  end
end
