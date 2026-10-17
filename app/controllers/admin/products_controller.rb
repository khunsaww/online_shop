class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: %i[show edit update destroy]
  before_action :set_categories, only: %i[new create edit update]

  def index
    @products = Product.includes(:category, :variants, image_attachment: :blob).order(created_at: :desc)
  end

  def show
  end

  def new
    @product = Product.new(published: false)
    @product.variants.build
  end

  def create
    @product = Product.new(product_params)
    if @product.save(context: :admin)
      redirect_to admin_product_path(@product), notice: "商品を作成しました"
    else
      @product.variants.build if @product.variants.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @product.assign_attributes(product_params)
    if @product.save(context: :admin)
      redirect_to admin_product_path(@product), notice: "商品を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.ordered_variants?
      redirect_to admin_products_path, alert: "注文で参照されている選択肢があるため削除できません。在庫を0にして販売を止めてください"
      return
    end

    @product.destroy!
    redirect_to admin_products_path, notice: "商品を削除しました"
  end

  private

  def set_product
    @product = Product.includes(:category, variants: :order_items, image_attachment: :blob).find(params[:id])
  end

  def set_categories
    @categories = Category.order(:position, :id)
  end

  def product_params
    params.require(:product).permit(
      :category_id, :name, :description, :published, :image,
      variants_attributes: %i[id option_kind_id label price stock _destroy]
    )
  end
end
