module XPF

  class InvalidArgumentError < Exception ; end

  module Arguments
    class << self

      def parse(*args)
        begin
          @configs ||= []
          if args.empty?
            new_matchers_and_config([], {})
          elsif args.size == 1
            is_config?(config = args[0]) ? new_matchers_and_config([], config) :
              new_matchers_and_config(args[0..0], {})
          elsif is_config?(config = args[-1])
            @configs << config
            new_matchers_and_config(args[0..-2], config)
          elsif args.all?{|arg| is_match_attrs?(arg) }
            new_matchers_and_config(args, {})
          else
            raise_args_err(__LINE__)
          end
        ensure
          @configs = nil
        end
      end

      def parse_with_config(args, config)
        @configs = [config]
        parse(*args)
      end

      private

        def new_matchers_and_config(match_args, config)
          _config = chained_config(config)
          [new_matchers(match_args, _config), new_config(_config)]
        end

        def new_matchers(match_args, config)
          match_args.map do |arg|
            if arg.is_a?(Array) && arg.size == 2 && is_config?(arg[-1])
              new_matcher(arg[0], chained_config(arg[1]))
            elsif arg.is_a?(Array) && arg.size == 1 && is_match_attrs?(arg[0])
              new_matcher(arg[0], config)
            elsif is_match_attrs?(arg)
              new_matcher(arg, config)
            else
              raise_args_err(__LINE__)
            end
          end.reject {|matcher| matcher.condition.nil? }
        end

        def chained_config(config)
          (@configs + [config]).inject({}){|memo, c| memo.merge(c) }
        end

#        def new_matcher(*args)
#          match_attrs, config = (0..1).map {|i| args[i] || {} }
#          [args.size < 3, is_config?(config), is_match_attrs?(match_attrs)].all? ?
#            new_matcher(match_attrs, config) : raise_args_err(__LINE__)
#        end

        def new_matcher(match_attrs, config)
          _config = new_config(config)
          _config.group_matcher.new(match_attrs, _config)
        end

        def new_config(config)
          Configuration.new(config)
        end

        def is_config?(arg)
          Configuration.describes_config?(arg)
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
