class Prefecture < ActiveHash::Base
  include ActiveHash::Associations

  self.data = [{ id: 0, name: "---" }] + JpPrefecture::Prefecture.all.map { |prefecture| { id: prefecture.code, name: prefecture.name } }
end
