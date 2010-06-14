module XPF
  module HTML
    module Matchers
      class Attribute < XPF::Matchers::Attribute

        def condition
          !("#{name}".downcase.to_sym == :class && value.is_a?(Array)) ? super : (
            value.map(&:to_s).map do |val|
              ma.apply_check_for_token(q(config.case_sensitive? ? val : val.downcase))
            end.join(' and ')
          )
        end

      end
    end
  end
end

