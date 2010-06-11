module XPF

  module Arguments
    class << self

      def parse(*args)
        if args.empty?
          matchers([{}], {})
        elsif args.size == 1
          matchers(args[0..0], {})
        elsif is_config?(config = args[-1])
          matchers(args[0..-2], config)
        elsif args.all?{|arg| is_match_attrs?(arg) }
          matchers(args, {})
        else
          raise_args_err(__LINE__)
        end
      end

      private

        def matchers(match_args, config)
          match_args.map do |arg|
            if arg.is_a?(Array) && arg.size == 2 && is_config?(arg[-1])
              matcher(*arg)
            elsif arg.is_a?(Array) && arg.size == 1 && is_match_attrs?(arg[0])
              matcher(arg[0], config)
            elsif is_match_attrs?(arg)
              matcher(arg, config)
            else
              raise_args_err(__LINE__)
            end
          end
        end

        def matcher(*args)
          match_attrs, config = (0..1).map {|i| args[i] || {} }
          [args.size < 3, is_config?(config), is_match_attrs?(match_attrs)].all? ?
            new_matcher(match_attrs, config) : raise_args_err(__LINE__)
        end

        def new_matcher(match_attrs, config)
          _config = Configuration.new(config)
          _config.group_matcher.new(match_attrs, _config)
        end

        def is_config?(arg)
          !arg.is_a?(Hash) ? false : (arg.keys - Configuration.to_hash.keys).empty?
        end

        def is_match_attrs?(arg)
          [Hash, Array].any?{|klass| arg.is_a?(klass) }
        end

        def raise_args_err(debug_line)
          raise InvalidArgumentError.new(%W|
            Expecting arguments to contain any permutations of the following fragments: \n
            (1) [{:attr1 => ..., ...}, {CONFIG}] and/or \n
            (2) [[:attr1, ...], {CONFIG}] and/or \n
            (3) {:attr1 => ..., ...} and/or \n
            (4) [:attr1, ...] and/or \n
            (5) {CONFIG} (*must be last if present)
          |.join(' ').squeeze(' '))
        end

    end
  end
end
