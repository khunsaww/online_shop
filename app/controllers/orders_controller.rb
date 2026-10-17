class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders.includes(:order_items).order(ordered_at: :desc)
  end

  def show
    @order = current_user.orders.includes(:order_items, :address).find(params[:id])
  end

  def new
    prepare_order_form
    return if performed?

    @order_form = OrderForm.new(user: current_user, cart: @cart)
    gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
  end

  def create
    prepare_order_form
    return if performed?

    @order_form = OrderForm.new(order_params.merge(user: current_user, cart: @cart, token: params[:token]))
    order = @order_form.save
    if order
      redirect_to order_path(order), notice: "注文が完了しました"
    else
      gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
      render :new, status: :unprocessable_entity
    end
  end

  private

  def prepare_order_form
    @cart = current_cart
    @cart_items = @cart.cart_items.includes(variant: { product: { image_attachment: :blob } }).order(:id)
    if @cart_items.empty?
      redirect_to cart_path, alert: "カートに商品がありません"
    elsif @cart.fulfillment_method_id.blank?
      redirect_to cart_path, alert: "受け渡し方法を選択してください"
    elsif @cart.checkout_blocked?
      redirect_to cart_path, alert: "在庫数を超えている商品があります。数量を変更してください"
    end
  end

  def order_params
    source = params[:order_form].presence || ActionController::Parameters.new
    source.permit(:postal_code, :prefecture_id, :city, :house_number, :building_name, :phone_number)
  end
end
