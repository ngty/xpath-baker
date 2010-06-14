module XPF
  module HTML
    module Matchers
      class Attribute < XPF::Matchers::Attribute

        def condition
          !("#{name}".downcase.to_sym == :class && value.is_a?(Array)) ? super : (
            value.map do |val|
              val = val.to_s.strip
              val = val.downcase unless config.case_sensitive?
              '(%s)' % [
                %|%s=#{q(val)}|,
                %|contains(%s,#{q(' %s '%val)})|,
                %|starts-with(%s,#{q('%s '%val)})|,
                %|starts-with(%s,#{q('%s '%val.reverse)})|,
              ].join(' or ') % ([ma]*4)
            end.join(' and ')
          )
        end

      end
    end
  end
end

