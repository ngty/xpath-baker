module XPF
  module HTML
    module Matchers
      module TR

        class Group < CM::Group

          def condition
            td_matchers, other_matchers = typed_matchers
            [
              td_matchers && ('%s' % td_matchers.map(&:condition).join('][')),
              other_matchers && mc(other_matchers.map(&:condition)),
            ].compact.join('')
          end

          def text_or_attr_matcher(name, val, config)
            name != :tds ? super : (
              klass = val == nil_value ? :'Nil' : :"#{val.class.to_s}"
              HM::TD.const_get(klass).new('./', val, config) rescue \
                raise InvalidMatchAttrError.new('Match attribute :tds must be a Hash or Array !!')
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
