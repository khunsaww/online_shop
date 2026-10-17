class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :variant

  validates :variant_id, uniqueness: { scope: :cart_id }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validate :quantity_does_not_exceed_stock
  validate :product_is_published

  def subtotal
    variant.price * quantity
  end

  def purchasable?
    product_is_for_sale? && quantity <= variant.stock
  end

  private

  def quantity_does_not_exceed_stock
    return if variant.blank? || quantity.blank?
    return if quantity <= variant.stock

    errors.add(:quantity, "が在庫数を超えています")
  end

  def product_is_published
    return if variant.blank? || product_is_for_sale?

    errors.add(:base, "この商品は現在購入できません")
  end

  def product_is_for_sale?
    variant.product.published?
  end
end
