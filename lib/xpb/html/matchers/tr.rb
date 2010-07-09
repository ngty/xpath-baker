module XPB
  module HTML
    module Matchers
      module TR

        class Group < CM::Group

          def condition
            td_matchers, other_matchers = typed_matchers
            (
              conditions = [
                td_matchers && ('%s' % td_matchers.map(&:condition).join('][')),
                mc((other_matchers || []).map(&:condition)),
              ].compact
            ).empty? ? nil : conditions.join('][')
          end

          def typed_matchers
            _matchers = matchers.group_by do |m|
              %w{Nil Hash Array}.any?{|klass| m.is_a?(HM::TD.const_get(klass)) }
            end
            [true, false].map{|key| _matchers[key] && _matchers[key] }
          end

          def typed_matcher(name, val, config)
            name != :tds ? super : new_typed_matcher(val, config)
          end

          def new_typed_matcher(val, config)
            klass = val == nil_value ? :'Nil' : :"#{val.class.to_s}"
            HM::TD.const_get(klass).new(val, config) rescue \
              raise InvalidMatchAttrError.new('Match attribute :tds must be a Hash or Array !!')
          end

        end

      end
    end
  end
end
