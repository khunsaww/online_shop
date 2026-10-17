class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    variant = Variant.joins(:product).merge(Product.published).find(params[:variant_id])
    quantity = params[:quantity].to_i
    item = current_cart.cart_items.find_or_initialize_by(variant: variant)
    item.quantity = item.quantity.to_i + quantity

    if quantity < 1
      redirect_to product_path(variant.product), alert: "数量を選択してください"
    elsif item.save
      redirect_to cart_path, notice: "カートに追加しました"
    else
      redirect_to product_path(variant.product), alert: item.errors.full_messages.to_sentence
    end
  end

  def update
    item = current_cart.cart_items.find(params[:id])
    if item.update(cart_item_params)
      redirect_to cart_path, notice: "数量を変更しました"
    else
      redirect_to cart_path, alert: item.errors.full_messages.to_sentence
    end
  end

  def destroy
    current_cart.cart_items.find(params[:id]).destroy!
    redirect_to cart_path, notice: "カートから削除しました"
  end

  private

  def cart_item_params
    params.require(:cart_item).permit(:quantity)
  end
end
