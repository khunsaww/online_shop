require "rails_helper"

RSpec.describe Variant, type: :model do
  it "価格は1円以上の整数" do
    expect(build(:variant, price: 0)).not_to be_valid
    expect(build(:variant, price: 1.5)).not_to be_valid
    expect(build(:variant, price: 1)).to be_valid
  end

  it "在庫は0以上の整数" do
    expect(build(:variant, stock: -1)).not_to be_valid
    expect(build(:variant, stock: 0)).to be_valid
  end

  it "注文で参照されている選択肢は削除できない" do
    item = create(:order_item)
    expect(item.variant.destroy).to be(false)
    expect(item.variant.reload).to be_persisted
  end
end
