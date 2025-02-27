class ActsController < ApplicationController
  before_action :authenticate_worker!
  before_action :set_client
  before_action :set_templates, only: %i[new]

  def new
    @act = @client.acts.build
    @acceptance_files = @client.acceptance_files
    @templates = Template.all
  end

  def index
    @acts = @client.acts.all
  end

  def create
    template = Template.find(act_params[:template_id])
    excel_file = @client.acceptance_files.find_by(
      blob_id: ActiveStorage::Blob.find_signed(
        act_params[:acceptance_file_id]
      ).id
    )

    if template.file.attached? && excel_file.present?
      DocumentGenerator.new(template, excel_file).generate
      redirect_to client_acts_path(@client), notice: "Акт успешно создан"
    else
      redirect_to new_client_act_path(@client),
                  alert: "Ошибка: отсутствует файл шаблона или Excel файл"
    end
  rescue => e
    Rails.logger.error "Ошибка при создании акта: #{e.message}"
    redirect_to new_client_act_path(@client),
                alert: "Произошла ошибка при создании акта"
  end

  def download
    file = ActiveStorage::Blob.find_signed params[:signed_id]

    if file
      attach = @client.acceptance_files.find_by(blob_id: file.id)

      attach.download do |data|
        send_data data, filename: attach.filename.to_s, type: attach.content_type
      end
    else
      redirect_to client_path(@client), alert: 'Файл не найден'
    end
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_templates
    @templates = Template.all
  end

  def act_params
    params.require(:act).permit(:template_id, :acceptance_file_id).merge(client_id: params[:client_id])
  end
end
