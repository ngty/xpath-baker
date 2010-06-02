module XPF

  class InvalidArgumentError < Exception ; end

  module ArgumentsParsing

    protected

      attr_reader :config, :scope

      def parse_args(*args)
        @scope, @config, match_attrs =
          case args[0]
          when nil then parse_scoped_args('//')
          when String then parse_scoped_args(*args)
          when Hash then parse_scoped_args(*['//', *args])
          else raise_invalid_arg_error
          end
        match_attrs
      end

      private

        def parse_scoped_args(*args)
          new_config = lambda {|config| Configuration.merge(config) }
          if args.size == 1
            [args[0], new_config[{}], {}]
          elsif args.size == 2 && args[1].is_a?(Hash)
            [args[0], new_config[{}], args[1]]
          elsif args.size == 3 && args[1..2].all? {|arg| arg.is_a?(Hash) }
            [args[0], new_config[args[2]], args[1]]
          else
            raise_invalid_arg_error
          end
        end

        def raise_invalid_arg_error
          raise InvalidArgumentError.new([
            'Expecting one of the following argument(s) group:',
            '(1) scope_str, match_attrs_hash & :config_hash',
            '(2) match_attrs_hash & :config_hash',
            '(3) match_attrs_hash',
            '(4) scope_str',
            '(5) (no args)',
          ].join(', '))
        end

  end
end
