class OrderForm
  include ActiveModel::Model

  attr_accessor :postal_code, :prefecture_id, :city, :house_number, :building_name, :phone_number,
                :token, :user, :cart

  validates :user, :cart, :token, presence: true
  validate :cart_has_items
  validate :fulfillment_is_selected
  validate :lines_are_purchasable

  with_options if: :delivery? do
    validates :postal_code, presence: true, format: { with: /\A[0-9]{3}-[0-9]{4}\z/, message: "はハイフンを含む形式で入力してください" }
    validates :city, :house_number, presence: true
    validates :phone_number, presence: true, format: { with: /\A\d{10,11}\z/, message: "はハイフンなしの10〜11桁で入力してください" }
    validates :prefecture_id, numericality: { other_than: 0, message: "を選択してください" }
  end

  def delivery?
    fulfillment_method_id == FulfillmentMethod::DELIVERY_ID
  end

  def pickup?
    fulfillment_method_id == FulfillmentMethod::PICKUP_ID
  end

  def fulfillment_method_id
    cart&.fulfillment_method_id
  end

  def total_price
    return 0 if cart.blank?

    cart.cart_items.includes(:variant).sum { |item| item.variant.price * item.quantity }
  end

  def save
    return false unless valid?

    lines = snapshot_lines
    return false if lines.blank?

    charge = create_charge(lines)
    return false if charge.blank?

    persist_order(lines, charge)
  end

  private

  def cart_has_items
    return if cart.blank? || cart.cart_items.any?

    errors.add(:base, "カートに商品がありません")
  end

  def fulfillment_is_selected
    return if cart.blank? || delivery? || pickup?

    errors.add(:base, "受け渡し方法を選択してください")
  end

  def lines_are_purchasable
    return if cart.blank?

    cart.cart_items.includes(variant: :product).each do |item|
      name = "#{item.variant.product.name}（#{item.variant.label}）"
      unless item.variant.product.published?
        errors.add(:base, "#{name}は現在購入できません")
      end
      if item.quantity > item.variant.stock
        errors.add(:base, "#{name}の在庫が不足しています")
      end
    end
  end

  def snapshot_lines
    lines = []
    Variant.transaction do
      lines = locked_lines
      lines.each { |line| validate_locked_line(line) }
      raise ActiveRecord::Rollback if errors.any?
    end
    return nil if errors.any?

    lines
  end

  def locked_lines
    items = cart.cart_items.order(:variant_id).to_a
    variants = Variant.lock.where(id: items.map(&:variant_id)).order(:id).index_by(&:id)
    products = Product.where(id: variants.values.map(&:product_id)).index_by(&:id)
    items.map do |item|
      variant = variants.fetch(item.variant_id)
      product = products.fetch(variant.product_id)
      {
        variant: variant,
        product: product,
        quantity: item.quantity,
        price: variant.price,
        product_name: product.name,
        variant_label: variant.label
      }
    end
  end

  def validate_locked_line(line)
    name = "#{line[:product_name]}（#{line[:variant_label]}）"
    errors.add(:base, "#{name}は現在購入できません") unless line[:product].published?
    errors.add(:base, "#{name}の在庫が不足しています") if line[:variant].stock < line[:quantity]
  end

  def create_charge(lines)
    Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
    Payjp::Charge.create(amount: charge_amount(lines), card: token, currency: "jpy")
  rescue Payjp::PayjpError => e
    Rails.logger.error("PAY.JP charge failed user_id=#{user.id} message=#{e.message}")
    errors.add(:base, "決済に失敗しました")
    nil
  end

  def persist_order(lines, charge)
    order = nil
    ActiveRecord::Base.transaction do
      fresh = locked_lines.index_by { |line| line[:variant].id }
      lines.each do |line|
        current = fresh[line[:variant].id]
        unchanged = current &&
                    current[:product].published? &&
                    current[:variant].stock >= line[:quantity] &&
                    current[:price] == line[:price]
        unless unchanged
          errors.add(:base, "在庫または価格が変わったため注文を確定できませんでした")
          raise ActiveRecord::Rollback
        end
      end

      order = user.orders.create!(
        fulfillment_method_id: fulfillment_method_id,
        status_id: OrderStatus::PREPARING,
        total_price: charge_amount(lines),
        ordered_at: Time.current
      )
      lines.each do |line|
        current = fresh.fetch(line[:variant].id)
        order.order_items.create!(
          variant: current[:variant],
          product_name: line[:product_name],
          variant_label: line[:variant_label],
          unit_price: line[:price],
          quantity: line[:quantity]
        )
        current[:variant].update!(stock: current[:variant].stock - line[:quantity])
      end
      order.create_address!(address_attributes) if delivery?
      cart.cart_items.destroy_all
      cart.update!(fulfillment_method_id: nil)
    end

    return order if order&.persisted?

    log_uncommitted_charge(charge)
    errors.add(:base, "注文を確定できませんでした。お手数ですが店舗へ連絡してください") if errors.none?
    nil
  rescue ActiveRecord::RecordInvalid => e
    log_uncommitted_charge(charge)
    Rails.logger.error("Order save failed after PAY.JP charge user_id=#{user.id} message=#{e.message}")
    errors.add(:base, "注文を確定できませんでした。お手数ですが店舗へ連絡してください")
    nil
  end

  def address_attributes
    {
      postal_code: postal_code,
      prefecture_id: prefecture_id,
      city: city,
      house_number: house_number,
      building_name: building_name,
      phone_number: phone_number
    }
  end

  def charge_amount(lines)
    lines.sum { |line| line[:price] * line[:quantity] }
  end

  def log_uncommitted_charge(charge)
    Rails.logger.error(
      "PAY.JP charge succeeded but order was not saved. charge_id=#{charge.id} user_id=#{user.id}"
    )
  end
end
