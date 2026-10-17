class Store
  def self.settings
    @settings ||= YAML.safe_load_file(Rails.root.join("config/store.yml"), aliases: true).fetch("shared")
  end

  def self.shop_name
    settings.fetch("name")
  end

  def self.address_lines
    prefecture = Prefecture.find_by(id: settings.fetch("prefecture_id"))
    [
      "〒#{settings.fetch('postal_code')}",
      [prefecture&.name, settings.fetch("city"), settings.fetch("house_number")].compact.join,
      settings["building_name"].presence,
      "電話 #{settings.fetch('phone_number')}"
    ].compact
  end
end
