module XPF
  module Matchers
    module Values
      class << self

        def regexp_condition(expr, value)
          condition = parse_regexp(value).to_condition
          count = (condition.length - condition.gsub('%s','').length) / 2
          condition % ([expr]*count)
        end

        def parse_regexp(value)
          (
            @regexp_parser ||= (
              require 'xpf/matchers/regexp'
              RegularExpressionParser.new
          )).parse(value.to_s)
        end

      end
    end
  end
end
