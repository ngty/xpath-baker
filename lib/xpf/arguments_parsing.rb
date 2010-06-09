module XPF

  class InvalidArgumentError < Exception ; end

  module ArgumentsParsing #:nodoc:

    protected

      def parse_args(*args)
        case args.size
        when 0 then return_parsed_args({}, {})
        when 1 then return_parsed_args(args.first, {})
        when 2 then return_parsed_args(*args)
        else raise_invalid_arg_error
        end
      end

    private

      def return_parsed_args(match_attrs, config)
        raise_invalid_arg_error unless [match_attrs, config].all? {|arg| arg.is_a?(Hash) }
        [
          match_attrs,
          Configuration.new(config)
        ]
      end

      def raise_invalid_arg_error
        raise InvalidArgumentError.new([
          'Expecting one of the following argument(s) group:',
          '(1) match_attrs_hash & :config_hash',
          '(2) match_attrs_hash',
          '(3) (no args)',
        ].join(', '))
      end

  end
end
