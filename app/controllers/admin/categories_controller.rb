class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = Category.order(:position, :id)
  end

  def new
    @category = Category.new(position: (Category.maximum(:position) || 0) + 1)
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_categories_path, notice: "カテゴリを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: "カテゴリを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.products.exists?
      redirect_to admin_categories_path, alert: "商品が残っているカテゴリは削除できません"
    else
      @category.destroy!
      redirect_to admin_categories_path, notice: "カテゴリを削除しました"
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :position)
  end
end
