class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def authenticate_worker!
    redirect_to root_path, alert: "Нет доступа!" unless current_user.is_a?(Worker)
  end

  def authenticate_client!
    redirect_to root_path, alert: "Нет доступа!" unless current_user.is_a?(Client)
  end
end
