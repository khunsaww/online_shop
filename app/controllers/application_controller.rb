class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_cart

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[last_name first_name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[last_name first_name])
  end

  def current_cart
    return unless user_signed_in?

    current_user.cart || current_user.create_cart!
  end

  def require_admin
    redirect_to root_path, alert: "管理者のみ利用できます" unless current_user&.admin?
  end
end
