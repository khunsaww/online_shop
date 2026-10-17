require "rails_helper"

RSpec.describe Order, type: :model do
  it "配達は準備中から配達中、配達完了へ進む" do
    order = create(:order)
    expect(order.transition_to!(OrderStatus::SHIPPING)).to be(true)
    expect(order.transition_to!(OrderStatus::DELIVERED)).to be(true)
    expect(order.transition_to!(OrderStatus::CANCELLED)).to be(false)
  end

  it "店舗受け取りは準備中から受取可能、受取完了へ進む" do
    order = create(:order, :pickup)
    expect(order.transition_to!(OrderStatus::SHIPPING)).to be(false)
    expect(order.transition_to!(OrderStatus::READY)).to be(true)
    expect(order.transition_to!(OrderStatus::PICKED_UP)).to be(true)
  end

  it "準備中だけキャンセルでき、在庫は戻さない" do
    variant = create(:variant, stock: 4)
    order = create(:order)
    create(:order_item, order: order, variant: variant, quantity: 2)
    expect(order.transition_to!(OrderStatus::CANCELLED)).to be(true)
    expect(variant.reload.stock).to eq(4)
    expect(order.transition_to!(OrderStatus::SHIPPING)).to be(false)
  end
end
