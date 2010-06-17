module XPF
  module HTML
    module Matchers
      module TR

        class Group < CM::Group

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
              HM::TD.const_get(klass).new('./', val, config) rescue \
                raise InvalidMatchAttrError.new('Match attribute :cells must be a Hash or Array !!')
            )
          end

          def typed_matchers
            _matchers = matchers.group_by do |m|
              %w{Nil Hash Array}.any?{|klass| m.is_a?(HM::TD.const_get(klass)) }
            end
            [true, false].map{|key| _matchers[key] && _matchers[key] }
          end

        end

      end
    end
  end
end
