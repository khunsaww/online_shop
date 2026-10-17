FactoryBot.define do
  factory :order do
    user
    fulfillment_method_id { FulfillmentMethod::DELIVERY_ID }
    status_id { OrderStatus::PREPARING }
    total_price { 320 }
    ordered_at { Time.current }

    trait :pickup do
      fulfillment_method_id { FulfillmentMethod::PICKUP_ID }
    end
  end
end
