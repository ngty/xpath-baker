module XPF

  module Matchers

    class Group < Matcher(:matchers, :config)

      def initialize(match_attrs, config)
        matchers = convert_to_matchers(match_attrs, config)
        super(matchers, config)
      end

      def condition
        mc(matchers.map(&:condition))
      end

      protected

        def convert_to_matchers(match_attrs, config)
          convert = match_attrs.is_a?(Hash) ? :convert_hash_to_matchers : :convert_array_to_matchers
          send(convert, match_attrs, config)
        end

        def convert_hash_to_matchers(match_attrs, config)
          match_attrs.map {|name, val| text_or_attr_matcher(name, val, config) }
        end

        def convert_array_to_matchers(match_attrs, config)
          match_attrs.map do |name_or_val|
            name_or_val.is_a?(String) ? config.literal_matcher.new(name_or_val, config) :
              text_or_attr_matcher(name_or_val, nil_value, config)
          end
        end

        def text_or_attr_matcher(name, val, config)
          new_config = lambda do |flag|
            Configuration.new(config.to_hash.merge(:include_inner_text => flag))
          end
          case name.to_s
          when /^@/ then config.attribute_matcher.new(name, val, config)
          when '~' then config.text_matcher.new(val, config)
          when '+' then config.text_matcher.new(val, new_config[true])
          when '-' then config.text_matcher.new(val, new_config[false])
          when '*' then config.any_text_matcher.new(val, config)
          else raise ArgumentError
          end
        end

    end

  end
end
