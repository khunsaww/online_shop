require "rails_helper"

RSpec.describe Category, type: :model do
  it "名前は必須で一意" do
    create(:category, name: "野菜")
    duplicate = build(:category, name: "野菜")
    expect(duplicate).not_to be_valid
  end

  it "商品が残っているカテゴリは削除できない" do
    product = create(:product)
    expect(product.category.destroy).to be(false)
  end
end
