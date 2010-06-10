module XPF
  module Matchers
    class Group

      attr_reader :axis_node, :attributes, :config

      def initialize(axis_node, attrs, config)
        @axis_node = (axn = axis_node || config.axis).include?('::') ? axn : "#{axn}::*"
        @config, @attributes = config, attrs.map do |name, value|
          name == :text ? Text.new(value, @config) : Attribute.new(name, value, @config)
        end
      end

      def conditions
        attributes.empty? ? nil : (
          '[%s]' % attributes.map(&:condition).join('][')
        )
      end

    end
  end
end
