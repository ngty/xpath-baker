module XPathFu

  settings = {
    :match_inner_text => true,
    :match_casing => true,
    :match_ordering => true
  }

  keys = settings.keys.map(&:to_s).sort.map(&:to_sym)
  Configuration = Struct.new(*keys).new(*keys.map {|k| settings[k] })

end
