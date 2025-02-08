class WorkersController < ApplicationController
  before_action :authenticate_worker!
  before_action :set_worker, only: [:show, :edit, :update]

  def show
  end

  def edit
  end

  def update
    if @worker.update(worker_params)
      redirect_to @worker, notice: "Профиль обновлен"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def authenticate_worker!
    redirect_to root_path, alert: "Нет доступа!" unless current_user.is_a?(Worker)
  end

  def set_worker
    @worker = Worker.find(params[:id])
  end

  def worker_params
    params.require(:worker).permit(:first_name, :middle_name, :last_name, :phone, :birth_date, :email, :gender, :position)
  end
end
