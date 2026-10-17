class Variant < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :product
  belongs_to :option_kind
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error

  validates :label, presence: true
  validates :option_kind_id, inclusion: { in: ->(_) { OptionKind.all.map(&:id) } }
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def stock_status
    return "在庫なし" if stock.to_i.zero?
    return "残りわずか" if stock <= 5

    "在庫あり"
  end

  def ordered?
    order_items.exists?
  end
end
