require 'rails_helper'

RSpec.describe Provider::MedicamentsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #request" do
    it "returns http success" do
      get :request
      expect(response).to have_http_status(:success)
    end
  end

end
