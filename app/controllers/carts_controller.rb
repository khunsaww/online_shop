class CartsController < ApplicationController
  before_action :authenticate_user!

  def show
    @cart = current_cart
    @cart_items = @cart.cart_items.includes(variant: { product: { image_attachment: :blob } }).order(:id)
  end

  def update
    @cart = current_cart
    if @cart.update(cart_params)
      redirect_to cart_path, notice: "受け渡し方法を保存しました"
    else
      @cart_items = @cart.cart_items.includes(variant: { product: { image_attachment: :blob } }).order(:id)
      flash.now[:alert] = @cart.errors.full_messages.to_sentence
      render :show, status: :unprocessable_entity
    end
  end

  private

  def cart_params
    params.require(:cart).permit(:fulfillment_method_id)
  end
end
