class ActsController < ApplicationController
  before_action :authenticate_worker!
  before_action :set_client
  before_action :set_templates, only: %i[new]

  def new
    @act = @client.acts.build
    @acceptance_files = @client.acceptance_files
  end

  def index
    @acts = @client.acts.all
  end

  def create

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
