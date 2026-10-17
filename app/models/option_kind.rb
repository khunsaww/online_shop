class OptionKind < ActiveHash::Base
  self.data = [
    { id: 1, name: "サイズ" },
    { id: 2, name: "重量" },
    { id: 3, name: "内容量" }
  ]
end
