require "rails_helper"

RSpec.describe Product, type: :model do
  it "画像がないと無効" do
    product = build(:product)
    product.image.detach
    expect(product).not_to be_valid
  end

  it "公開フラグは真偽値だけを受け付ける" do
    product = build(:product, published: nil)
    expect(product).not_to be_valid
  end

  it "在庫がすべて0なら在庫なし" do
    product = create(:product)
    create(:variant, product: product, stock: 0)
    expect(product.stock_status).to eq("在庫なし")
    expect(product).to be_sold_out
  end

  it "在庫が1から5なら残りわずか" do
    product = create(:product)
    create(:variant, product: product, stock: 3)
    expect(product.stock_status).to eq("残りわずか")
  end
end
