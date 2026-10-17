class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :variant

  validates :product_name, :variant_label, presence: true
  validates :unit_price, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  def subtotal
    unit_price * quantity
  end
end
