require "rails_helper"

RSpec.describe OrderItem, type: :model do
  it "注文時の単価と数量を持つ" do
    item = create(:order_item, unit_price: 450, quantity: 2)
    expect(item.subtotal).to eq(900)
  end
end
