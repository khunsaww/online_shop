class Cart < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to :fulfillment_method, optional: true
  has_many :cart_items, dependent: :destroy

  validates :user_id, uniqueness: true
  validates :fulfillment_method_id, inclusion: { in: ->(_) { FulfillmentMethod.all.map(&:id) } }, allow_nil: true

  def delivery?
    fulfillment_method_id == FulfillmentMethod::DELIVERY_ID
  end

  def pickup?
    fulfillment_method_id == FulfillmentMethod::PICKUP_ID
  end

  def total_price
    cart_items.sum(&:subtotal)
  end

  def checkout_blocked?
    cart_items.any? { |item| !item.purchasable? }
  end
end
