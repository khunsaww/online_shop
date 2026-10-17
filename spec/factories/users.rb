FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "customer#{n}@example.com" }
    password { "password1" }
    password_confirmation { "password1" }
    last_name { "山田" }
    first_name { "花" }
    role_id { Role::CUSTOMER_ID }

    trait :admin do
      role_id { Role::ADMIN_ID }
    end
  end
end
