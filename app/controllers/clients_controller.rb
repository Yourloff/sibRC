class ClientsController < ApplicationController
  before_action :authenticate_worker!
  before_action :set_client, except: %i[new create]

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
    @acts = @client.acts
  end

  def edit
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

  # Загрузка файлов
  def upload_acceptance_files
    files = params[:client][:acceptance_files]

    files.each do |file|
      next if file.blank?
      @client.acceptance_files.attach(io: file.tempfile, filename: file.original_filename, content_type: file.content_type)
    end

    redirect_to @client
  end

  def delete_acceptance_file
    blob = ActiveStorage::Blob.find_signed(params[:file_id])

    if blob
      attachment = @client.acceptance_files.find_by(blob_id: blob.id)
      attachment&.purge
      blob.purge

      flash[:notice] = 'Файл удален'
    else
      flash[:alert] = 'Файл не найден'
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("file_#{params[:file_id]}") }
      format.html { redirect_to @client }
    end
  end

  private

  def set_client
    @client = Client.find(params[:id] || params[:client_id])
  end

  def authenticate_worker!
    redirect_to root_path, alert: "Нет доступа!" unless current_user.is_a?(Worker)
  end

  def client_params
    params.require(:client).permit(:first_name, :middle_name, :last_name, :inn, :kpp, :customer, :address, :phone, :type, :email)
  end
end
