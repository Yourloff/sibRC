class ClientsController < ApplicationController
  before_action :authenticate_worker!

  def index
    @clients = Client.all
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    if @client.save
      redirect_to clients_path, notice: "Клиент добавлен"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @client = Client.find(params[:id])
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])
    if @client.update(client_params)
      redirect_to clients_path, notice: "Данные обновлены"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    redirect_to clients_path, notice: "Клиент удален"
  end

  private

  def authenticate_worker!
    redirect_to root_path, alert: "Нет доступа!" unless current_user.is_a?(Worker)
  end

  def client_params
    params.require(:client).permit(:first_name, :middle_name, :last_name, :inn, :kpp, :customer, :address, :phone, :type, :email)
  end
end
