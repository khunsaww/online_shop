FactoryBot.define do
  factory :product do
    category
    sequence(:name) { |n| "トマト#{n}" }
    description { "完熟のトマトです" }
    published { true }

    after(:build) do |product|
      next if product.image.attached?

      product.image.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/sample.png")),
        filename: "sample.png",
        content_type: "image/png"
      )
    end
  end
end
