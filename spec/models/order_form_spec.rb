require "rails_helper"

RSpec.describe OrderForm, type: :model do
  let(:user) { create(:user) }
  let(:variant) { create(:variant, price: 500, stock: 4) }
  let(:cart) { user.cart }

  before do
    cart.update!(fulfillment_method_id: FulfillmentMethod::DELIVERY_ID)
    cart.cart_items.create!(variant: variant, quantity: 2)
    allow(Payjp::Charge).to receive(:create).and_return(double("charge", id: "ch_test"))
  end

  def form(attrs = {})
    OrderForm.new({
      user: user,
      cart: cart,
      token: "tok_test",
      postal_code: "150-0001",
      prefecture_id: 13,
      city: "渋谷区",
      house_number: "1-2-3",
      phone_number: "09012345678"
    }.merge(attrs))
  end

  it "配達では住所とトークンが必要" do
    expect(form(token: nil, postal_code: nil)).not_to be_valid
  end

  it "店舗受け取りでは住所を検証しない" do
    cart.update!(fulfillment_method_id: FulfillmentMethod::PICKUP_ID)
    order = form(postal_code: nil, prefecture_id: nil, city: nil, house_number: nil, phone_number: nil).save
    expect(order).to be_persisted
    expect(order.address).to be_nil
    expect(order.total_price).to eq(1000)
  end

  it "在庫を超える注文は拒否し、課金しない" do
    cart.cart_items.first.update_column(:quantity, 5)
    expect(form.save).to be_falsey
    expect(Payjp::Charge).not_to have_received(:create)
    expect(variant.reload.stock).to eq(4)
  end

  it "注文時の価格を明細へ残し、在庫を減らし、カートを空にする" do
    order = form.save
    expect(order.order_items.first.unit_price).to eq(500)
    expect(order.order_items.first.variant_id).to eq(variant.id)
    expect(variant.reload.stock).to eq(2)
    expect(cart.cart_items.reload).to be_empty
  end

  it "画面から送られた単価は受け取らず、データベースの価格で合計する" do
    variant.update!(price: 700)
    order = form.save
    expect(order.total_price).to eq(1400)
    expect(order.order_items.first.unit_price).to eq(700)
  end

  it "課金に失敗したときは注文も在庫も変えない" do
    allow(Payjp::Charge).to receive(:create).and_raise(Payjp::CardError.new("declined", "card", "card_declined"))
    expect(form.save).to be_falsey
    expect(Order.count).to eq(0)
    expect(variant.reload.stock).to eq(4)
  end
end
