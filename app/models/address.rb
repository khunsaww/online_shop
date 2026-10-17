class Address < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :order
  belongs_to :prefecture

  validates :postal_code, presence: true, format: { with: /\A[0-9]{3}-[0-9]{4}\z/, message: "はハイフンを含む形式で入力してください" }
  validates :city, :house_number, presence: true
  validates :phone_number, presence: true, format: { with: /\A\d{10,11}\z/, message: "はハイフンなしの10〜11桁で入力してください" }
  validates :prefecture_id, numericality: { other_than: 0, message: "を選択してください" }
end
