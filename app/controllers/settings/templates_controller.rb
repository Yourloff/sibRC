class Settings::TemplatesController < ApplicationController
  def index
    @templates = Template.all
  end

  def new
    @template = Template.new
  end

  def edit
    @template = Template.find(params[:id])
  end

  def update
    @template = Template.find(params[:id])

    if @template.update(template_params)
      redirect_to settings_templates_path, notice: 'Шаблон успешно обновлен!'
    else
      render :edit
    end
  end

  def create
    @template = Template.new(template_params)

    if @template.save
      redirect_to settings_templates_path, notice: 'Шаблон успешно загружен!'
    else
      render :new
    end
  end

  private

  def template_params
    params.require(:template).permit(:file, :metadata, :title)
  end
end
