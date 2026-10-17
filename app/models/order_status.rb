class OrderStatus < ActiveHash::Base
  self.data = [
    { id: 1, name: "準備中" },
    { id: 2, name: "配達中" },
    { id: 3, name: "配達完了" },
    { id: 4, name: "受取可能" },
    { id: 5, name: "受取完了" },
    { id: 6, name: "キャンセル" }
  ]

  PREPARING = 1
  SHIPPING = 2
  DELIVERED = 3
  READY = 4
  PICKED_UP = 5
  CANCELLED = 6

  TERMINAL_IDS = [DELIVERED, PICKED_UP, CANCELLED].freeze

  def self.allowed_next_ids(fulfillment_method_id, status_id)
    case [fulfillment_method_id, status_id]
    when [FulfillmentMethod::DELIVERY_ID, PREPARING] then [SHIPPING, CANCELLED]
    when [FulfillmentMethod::DELIVERY_ID, SHIPPING] then [DELIVERED]
    when [FulfillmentMethod::PICKUP_ID, PREPARING] then [READY, CANCELLED]
    when [FulfillmentMethod::PICKUP_ID, READY] then [PICKED_UP]
    else []
    end
  end
end
