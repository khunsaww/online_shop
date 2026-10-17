class ProductsController < ApplicationController
  def index
    @categories = Category.order(:position, :id)
    @products = Product.published.includes(:category, :variants, image_attachment: :blob).order(created_at: :desc)
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
    if params[:keyword].present?
      keyword = "%#{Product.sanitize_sql_like(params[:keyword].strip)}%"
      @products = @products.where("products.name LIKE :keyword OR products.description LIKE :keyword", keyword: keyword)
    end
    @selected_category = @categories.find { |category| category.id.to_s == params[:category_id].to_s }
  end

  def show
    @product = Product.includes(:category, :variants, image_attachment: :blob).find(params[:id])
    raise ActiveRecord::RecordNotFound unless @product.visible_to?(current_user)
  end
end
