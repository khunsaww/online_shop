require "rails_helper"

RSpec.describe Cart, type: :model do
  it "ユーザーにつき1つ" do
    user = create(:user)
    expect(Cart.new(user: user)).not_to be_valid
  end
end
