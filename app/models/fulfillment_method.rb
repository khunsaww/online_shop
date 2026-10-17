class FulfillmentMethod < ActiveHash::Base
  self.data = [
    { id: 1, name: "配達" },
    { id: 2, name: "店舗受け取り" }
  ]

  DELIVERY_ID = 1
  PICKUP_ID = 2
end
