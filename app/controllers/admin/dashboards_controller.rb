class Admin::DashboardsController < Admin::BaseController
  def show
    @preparing_count = Order.where(status_id: OrderStatus::PREPARING).count
    @low_stock_variants = Variant.includes(:product).where(stock: 1..5).order(:stock, :id)
    @out_of_stock_variants = Variant.includes(:product).where(stock: 0).order(:id)
  end
end
