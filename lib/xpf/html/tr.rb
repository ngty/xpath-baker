module XPF
  module HTML
    module TR

      def tr(*args)
        XPath.new(:tr, :group_matcher => TR::Matchers::Group).build(*args)
      end

      private

        module Matchers

          class Group < XPF::Matchers::Group

            HMC = HTML::Matchers::Cells

            def condition
              cell_matchers, other_matchers = typed_matchers
              [
                cell_matchers && ('%s' % cell_matchers.map(&:condition).join('][')),
                other_matchers && mc(other_matchers.map(&:condition)),
              ].compact.join('')
            end

            def text_or_attr_matcher(name, val, config)
              name != :cells ? super : (
                klass = val == nil_value ? :'Nil' : :"#{val.class.to_s}"
                HMC.const_get(klass).new('./', val, config) rescue \
                  raise InvalidMatchAttrError.new('Match attribute :cells must be a Hash or Array !!')
              )
            end

            def typed_matchers
              _matchers = matchers.group_by do |m|
                [HMC::Nil, HMC::Hash, HMC::Array].any?{|klass| m.is_a?(klass) }
              end
              [true, false].map{|key| _matchers[key] ? _matchers[key] : nil }
            end

          end

        end

    end
  end
end
