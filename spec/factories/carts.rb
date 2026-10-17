FactoryBot.define do
  factory :cart do
    user
    fulfillment_method_id { FulfillmentMethod::DELIVERY_ID }
    initialize_with { user.cart }
  end
end
