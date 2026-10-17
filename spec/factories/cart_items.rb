FactoryBot.define do
  factory :cart_item do
    cart
    variant
    quantity { 1 }
  end
end
