module XPF
  module HTML
    module Matchers
      class Attribute < XPF::Matchers::Attribute

        def condition
          !("#{name}".downcase.to_sym == :class && value.is_a?(Array)) ? super : (
            value.map do |val|
              tokens = [c(n("@#{name}")), val.strip]*4
              '(%s)' % [
                %|%s=#{c(q('%s'))}|,
                %|contains(%s,#{c(q(' %s '))})|,
                %|starts-with(%s,#{c(q('%s '))})|,
                %|ends-with(%s,#{c(q(' %s'))})|
              ].join(' or ') % tokens
            end.join(' and ')
          )
        end

      end
    end
  end
end

