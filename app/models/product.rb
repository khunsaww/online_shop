class Product < ApplicationRecord
  belongs_to :category
  has_many :variants, dependent: :destroy
  has_one_attached :image
  accepts_nested_attributes_for :variants, allow_destroy: true, reject_if: :reject_blank_variant?

  validates :name, :description, presence: true
  validates :published, inclusion: { in: [true, false] }
  validate :image_must_be_attached
  validate :must_have_variant, on: :admin

  scope :published, -> { where(published: true) }

  def visible_to?(user)
    published? || user&.admin?
  end

  def display_price
    variants.map(&:price).min
  end

  def stock_status
    stocks = variants.map(&:stock)
    return "在庫なし" if stocks.empty? || stocks.all?(&:zero?)
    return "残りわずか" if stocks.max <= 5

    "在庫あり"
  end

  def sold_out?
    variants.none? { |variant| variant.stock.positive? }
  end

  def ordered_variants?
    variants.joins(:order_items).exists?
  end

  private

  def reject_blank_variant?(attributes)
    attributes["label"].blank? && attributes["price"].blank? && attributes["id"].blank?
  end

  def image_must_be_attached
    errors.add(:image, "を入力してください") unless image.attached?
  end

  def must_have_variant
    remaining = variants.reject(&:marked_for_destruction?)
    errors.add(:base, "選択肢を1つ以上登録してください") if remaining.empty?
  end
end
