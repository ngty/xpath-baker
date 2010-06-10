module XPF

  class InvalidAxisNodeError < Exception ; end

  module Matchers

    class Group < Matcher(:axis_node, :matchers, :config)

      def initialize(axis_node, match_attrs, config)
        super(
          (axn = (axis_node || config.axis).to_s.gsub('_','-')).include?('::') ? axn : "#{axn}::*",
          match_attrs.map{|name, value| new_matcher(name, value, config) },
          config
        )
        ensure_valid_axis_node!
      end

      def condition
        matchers.empty? ? nil : (
          './%s[%s]' % [axis_node, matchers.map(&:condition).join('][')]
        )
      end

      private

        def ensure_valid_axis_node!
          begin
            axis = axis_node.split('::').first.gsub('-','_').to_sym
            Configuration.send(:is_valid_axis!, 'fake', axis)
          rescue InvalidConfigSettingValueError
            raise InvalidAxisNodeError.new("Axis node '#{axis_node}' descibes an invalid axis !!")
          end
        end

        def new_matcher(name, value, config)
          name == :text ? Text.new(value, config) : Attribute.new(name, value, config)
        end

    end

  end
end
