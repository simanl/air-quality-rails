require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  describe "GET /forecasts" do
    it "works! (now write some real specs)" do
      get forecasts_path
      expect(response).to have_http_status(200)
    end
  end
end
