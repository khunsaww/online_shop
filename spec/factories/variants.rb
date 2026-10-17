FactoryBot.define do
  factory :variant do
    product
    option_kind_id { 2 }
    label { "500g" }
    price { 320 }
    stock { 10 }
  end
end
