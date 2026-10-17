module ApplicationHelper
  def yen(amount)
    return "-" if amount.nil?

    "¥#{number_with_delimiter(amount)}"
  end

  def stock_class(status)
    case status
    when "在庫なし" then "badge badge-empty"
    when "残りわずか" then "badge badge-low"
    else "badge badge-ok"
    end
  end

  def product_image_tag(product, **options)
    return unless product.image.attached?

    image_tag product.image, **options
  end
end
