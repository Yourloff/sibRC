class WorkersController < ApplicationController
  before_action :authenticate_worker!

  def show
    @worker = Worker.find(params[:id])
  end

  private

  def authenticate_worker!
    redirect_to root_path, alert: "Нет доступа!" unless current_user.is_a?(Worker)
  end
end
