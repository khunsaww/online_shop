require "rails_helper"

RSpec.describe "Admin dashboard", type: :request do
  it "管理者以外はトップへ戻す" do
    sign_in create(:user)
    get admin_root_path
    expect(response).to redirect_to(root_path)
  end

  it "管理者は未対応件数を見られる" do
    sign_in create(:user, :admin)
    create(:order)
    get admin_root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("未対応注文")
  end

  it "非公開商品は管理者以外には開かない" do
    product = create(:product, published: false)
    create(:variant, product: product)
    get product_path(product)
    expect(response).to have_http_status(:not_found)

    sign_in create(:user, :admin)
    get product_path(product)
    expect(response).to have_http_status(:ok)
  end
end
