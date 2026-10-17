require "rails_helper"

RSpec.describe "Orders", type: :request do
  let(:user) { create(:user) }
  let(:variant) { create(:variant, price: 400, stock: 3) }

  before do
    user.cart.update!(fulfillment_method_id: FulfillmentMethod::PICKUP_ID)
    user.cart.cart_items.create!(variant: variant, quantity: 1)
    allow(Payjp::Charge).to receive(:create).and_return(double("charge", id: "ch_request"))
  end

  it "未ログインでは注文画面を開けない" do
    get new_order_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it "本人以外の注文詳細は開けない" do
    order = create(:order)
    sign_in user
    get order_path(order)
    expect(response).to have_http_status(:not_found)
  end

  it "注文を作成すると在庫が減り、明細に価格が残り、カートが空になる" do
    sign_in user
    post orders_path, params: { token: "tok_request", order_form: { postal_code: "999-9999" } }
    order = Order.last
    expect(response).to redirect_to(order_path(order))
    expect(variant.reload.stock).to eq(2)
    expect(order.order_items.first.unit_price).to eq(400)
    expect(user.cart.cart_items).to be_empty
  end
end
