require 'rails_helper'

RSpec.describe "Acts", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/acts/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/acts/create"
      expect(response).to have_http_status(:success)
    end
  end

end
