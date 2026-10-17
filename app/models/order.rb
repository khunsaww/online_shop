class Order < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to :fulfillment_method
  belongs_to_active_hash :order_status, foreign_key: :status_id, class_name: "OrderStatus"
  has_many :order_items, dependent: :destroy
  has_one :address, dependent: :destroy

  validates :total_price, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :ordered_at, presence: true
  validates :status_id, inclusion: { in: ->(_) { OrderStatus.all.map(&:id) } }
  validates :fulfillment_method_id, inclusion: { in: ->(_) { FulfillmentMethod.all.map(&:id) } }

  def delivery?
    fulfillment_method_id == FulfillmentMethod::DELIVERY_ID
  end

  def pickup?
    fulfillment_method_id == FulfillmentMethod::PICKUP_ID
  end

  def transition_to!(next_status_id)
    next_status_id = next_status_id.to_i
    allowed = OrderStatus.allowed_next_ids(fulfillment_method_id, status_id)
    unless allowed.include?(next_status_id)
      errors.add(:status_id, "には変更できません")
      return false
    end

    update!(status_id: next_status_id)
  end
end
