module XPF
  class XPath

    def initialize(name, config = {})
      @name, @config = name, config
    end

    def build(*args)
      matchers, config = Arguments.parse_with_config(args, @config)
      conditions = matchers.empty? ? nil : ('[%s]' % matchers.map(&:condition).join(']['))
      greed = config.greedy? ? nil : "[not(.//#{@name})]"
      [config.scope, @name].join('') +
        case (pos = config.position.to_s)
        when '' then '%s%s' % [greed, conditions]
        when /^\^/ then '[%s]%s%s' % [pos.sub(/^\^/,''), greed, conditions]
        else '%s%s[%s]' % [greed, conditions, pos.sub(/\$$/,'')]
        end
    end

  end
end
