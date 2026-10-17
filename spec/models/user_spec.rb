require "rails_helper"

RSpec.describe User, type: :model do
  it "パスワードに英字と数字の両方を求める" do
    user = build(:user, password: "password", password_confirmation: "password")
    expect(user).not_to be_valid
    expect(user.errors[:password]).to be_present
  end

  it "登録時の役割はお客様になる" do
    user = create(:user, role_id: nil)
    expect(user.role_id).to eq(Role::CUSTOMER_ID)
    expect(user.cart).to be_present
  end
end
