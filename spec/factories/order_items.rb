FactoryBot.define do
  factory :order_item do
    order
    variant
    product_name { "トマト" }
    variant_label { "500g" }
    unit_price { 320 }
    quantity { 1 }
  end
end
