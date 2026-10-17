FactoryBot.define do
  factory :address do
    order
    postal_code { "150-0001" }
    prefecture_id { 13 }
    city { "渋谷区" }
    house_number { "1-2-3" }
    building_name { "マルシェビル" }
    phone_number { "09012345678" }
  end
end
