module XPF
  class XPath

    def initialize(name, config = {})
      @name, @config = name, config
    end

    def build(*args)
      matchers, config = Arguments.parse_with_config(args, @config)
      conditions = matchers.empty? ? nil : ('[%s]' % matchers.map(&:condition).join(']['))
      prefix = '%s%s' % [config.scope, @name]
      case (pos = config.position.to_s)
      when '' then '%s%s' % [prefix, conditions]
      when /^\^/ then '%s[%s]%s' % [prefix, pos.sub(/^\^/,''), conditions]
      else '%s%s[%s]' % [prefix, conditions, pos.sub(/\$$/,'')]
      end
    end

  end
end
