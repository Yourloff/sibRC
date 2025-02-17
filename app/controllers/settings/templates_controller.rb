class Settings::TemplatesController < ApplicationController
  before_action :set_template, only: %i[edit update]

  def index
    @templates = Template.all
  end

  def new
    @template = Template.new
  end

  def edit; end

  def update
    metadata = params[:template][:metadata]
    file = params[:template][:file]
    @template.update(title: template_params[:title])

    if file.present?
      @template.file.attach(io: file.tempfile, filename: file.original_filename, content_type: file.content_type)
    end

    if metadata.present?
      @template.metadata.attach(io: metadata.tempfile, filename: metadata.original_filename, content_type: metadata.content_type)
    end

    if @template.save
      redirect_to settings_templates_path, notice: 'Шаблон успешно обновлен!'
    else
      render :edit
    end
  end

  def create
    @template = Template.new(template_params)

    metadata = params[:template][:metadata]
    file = params[:template][:file]

    if file.present?
      @template.file.attach(io: file.tempfile, filename: file.original_filename, content_type: file.content_type)
    end

    if metadata.present?
      @template.metadata.attach(io: metadata.tempfile, filename: metadata.original_filename, content_type: metadata.content_type)
    end

    if @template.save
      redirect_to settings_templates_path, notice: 'Шаблон успешно загружен!'
    else
      render :new
    end
  end

  def destroy
    @template = Template.find(params[:id])

    @template.file.purge if @template.file.attached?
    @template.metadata.purge if @template.metadata.attached?

    @template.destroy

    redirect_to settings_templates_path, notice: 'Шаблон успешно удалён.'
  end

  private

  def set_template
    @template = Template.find(params[:id])
  end

  def template_params
    params.require(:template).permit(:file, :metadata, :title)
  end
end
