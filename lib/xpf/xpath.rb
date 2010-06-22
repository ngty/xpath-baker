module XPF
  class XPath

    def initialize(name, config = {})
      @name, @config = name, config
    end

    def build(*args)
      matchers, config = Arguments.parse_with_config(args, @config)
      conditions = matchers.empty? ? nil : ('[%s]' % matchers.map(&:condition).join(']['))
      conditions = "[not(.//#{@name})]#{conditions}" unless config.greedy?
      "#{config.scope}#{@name}%s#{conditions}%s" %
        ((pos = config.position).nil? ? [nil,nil] : (pos.start? ? [pos,nil] : [nil,pos]))
    end

  end
end
