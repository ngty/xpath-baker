module XPathFu

  settings = {
    :case_sensitive => true,
    :match_ordering => true,
    :include_inner_text => true,
    :normalize_space => true
  }

  keys = settings.keys.map(&:to_s).sort.map(&:to_sym)
  Configuration = Struct.new(*keys).new(*keys.map {|k| settings[k] })

end
