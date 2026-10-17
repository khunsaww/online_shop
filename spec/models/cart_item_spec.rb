require "rails_helper"

RSpec.describe CartItem, type: :model do
  it "数量は1以上かつ在庫以下" do
    variant = create(:variant, stock: 2)
    cart = create(:user).cart
    expect(build(:cart_item, cart: cart, variant: variant, quantity: 0)).not_to be_valid
    expect(build(:cart_item, cart: cart, variant: variant, quantity: 3)).not_to be_valid
    expect(build(:cart_item, cart: cart, variant: variant, quantity: 2)).to be_valid
  end
end
