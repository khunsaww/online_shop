require "rails_helper"

RSpec.describe "Cart items", type: :request do
  it "未ログインのカート追加はログイン画面へ送る" do
    variant = create(:variant)
    post cart_items_path, params: { variant_id: variant.id, quantity: 1 }
    expect(response).to redirect_to(new_user_session_path)
  end

  it "他人のカート明細は変更できない" do
    owner = create(:user)
    item = owner.cart.cart_items.create!(variant: create(:variant), quantity: 1)
    sign_in create(:user)
    patch cart_item_path(item), params: { cart_item: { quantity: 2 } }
    expect(response).to have_http_status(:not_found)
    expect(item.reload.quantity).to eq(1)
  end
end
