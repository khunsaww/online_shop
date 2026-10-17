require "rails_helper"

RSpec.describe Address, type: :model do
  it "郵便番号と電話番号の形式を確認する" do
    address = build(:address, postal_code: "1234567", phone_number: "090-1234-5678", prefecture_id: 0)
    expect(address).not_to be_valid
    expect(address.errors[:postal_code]).to be_present
    expect(address.errors[:phone_number]).to be_present
    expect(address.errors[:prefecture_id]).to be_present
  end

  it "建物名は空でも有効" do
    expect(build(:address, building_name: "")).to be_valid
  end
end
