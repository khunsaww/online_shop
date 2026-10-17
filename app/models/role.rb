class Role < ActiveHash::Base
  self.data = [
    { id: 1, name: "お客様" },
    { id: 2, name: "管理者" }
  ]

  CUSTOMER_ID = 1
  ADMIN_ID = 2
end
