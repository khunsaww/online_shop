class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: %i[show update]

  def index
    @orders = Order.includes(:user, :order_items).order(ordered_at: :desc)
  end

  def show
    @next_statuses = OrderStatus.allowed_next_ids(@order.fulfillment_method_id, @order.status_id).map { |id| OrderStatus.find(id) }
  end

  def update
    if @order.transition_to!(params.dig(:order, :status_id))
      redirect_to admin_order_path(@order), notice: "受け渡し状態を更新しました"
    else
      redirect_to admin_order_path(@order), alert: @order.errors.full_messages.to_sentence
    end
  end

  private

  def set_order
    @order = Order.includes(:user, :address, order_items: :variant).find(params[:id])
  end
end
