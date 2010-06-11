module XPF
  module HTML
    module Matchers
      class Attribute < XPF::Matchers::Attribute

        def condition
          !("#{name}".downcase.to_sym == :class && value.is_a?(Array)) ? super : (
            value.map do |val|
              expr, val = c(n("@#{name}")), val.strip
              '(%s)' % %W|
                %s=#{c(q(val))}
                contains(%s,#{c(q(' %s '))})
                starts-with(%s,#{c(q('%s '))})
                ends-with(%s,#{c(q(' %s'))})
              |.join(' or ') % ([expr,val]*4)
            end.join(' and ')
          )
        end

      end
    end
  end
end

