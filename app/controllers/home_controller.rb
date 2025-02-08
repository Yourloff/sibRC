class HomeController < ApplicationController
  def index

    @clients = Client.all
  end
end
