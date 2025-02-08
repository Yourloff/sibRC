class ActsController < ApplicationController
  before_action :authenticate_worker!
  before_action :set_client

  def new
    @act = @client.acts.build
    @templates = Template.all
  end

  def create
    @act = @client.acts.build(act_params)
    if @act.save
      uploaded_file = params[:act][:file]
      @act.file.attach(uploaded_file)

      redirect_to client_path(@client), notice: "Акт успешно добавлен"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def act_params
    params.require(:act).permit(:template_id, :file)
  end
end
