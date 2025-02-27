class ActsController < ApplicationController
  before_action :authenticate_worker!
  before_action :set_client
  before_action :set_templates, only: %i[new]

  def new
    @act = @client.acts.build
    @acceptance_files = @client.acceptance_files
  end

  def create
    template = Template.find(act_params[:template_id])
    excel_file = @client.acceptance_files.find_by(
      blob_id: ActiveStorage::Blob.find_signed(act_params[:acceptance_file_id]).id
    )

    if template.file.attached? && excel_file.present?
      generated_file = DocumentGenerator.new(template, excel_file).generate
      @act = @client.acts.build(template: template)
      @act.file.attach(
        io: StringIO.new(generated_file),
        filename: "act_#{Time.current.to_i}.docx",
        content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      )
      if @act.save
        redirect_to client_acts_path(@client), notice: "Акт успешно создан"
      else
        redirect_to new_client_act_path(@client), alert: "Ошибка при сохранении акта"
      end
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
    file = ActiveStorage::Blob.find_signed(params[:signed_id])
    if file
      attach = @client.acceptance_files.find_by(blob_id: file.id)
      send_data attach.download, filename: attach.filename.to_s, type: attach.content_type
    else
      redirect_to client_path(@client), alert: "Файл не найден"
    end
  end

  def upload_edited
    signed_id = params[:signed_id]
    file = params[:acceptance_file]

    if file && signed_id
      blob = ActiveStorage::Blob.find_signed(signed_id)
      if blob
        blob.upload(file)
        render json: { success: true, signed_id: blob.signed_id }
      else
        render json: { success: false, message: "Файл не найден" }, status: :not_found
      end
    else
      render json: { success: false, message: "Файл или идентификатор не предоставлены" }, status: :unprocessable_entity
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