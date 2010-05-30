module XPathFu

  class ConfigSettingNotSupportedError < Exception ; end

  settings = {
    :case_sensitive => true,
    :match_ordering => true,
    :include_inner_text => true,
    :normalize_space => true
  }

  keys = settings.keys.map(&:to_s).sort.map(&:to_sym)
  Configuration = Struct.new(*keys).new(*keys.map {|k| settings[k] })

  class << Configuration
    def merge(settings)
      config = self.dup
      settings.each do |setting, val|
        config.send(:"#{setting}=", val) rescue \
          raise ConfigSettingNotSupportedError.new("Config setting :#{setting} is not supported !!")
      end
      config
    end
  end

end
