require 'rails_helper'

RSpec.describe ForecastsController, type: :controller do

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ForecastsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all forecasts as @forecasts" do
      forecast = Forecast.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:forecasts)).to eq([forecast])
    end
  end

  describe "GET #show" do
    it "assigns the requested forecast as @forecast" do
      forecast = Forecast.create! valid_attributes
      get :show, {:id => forecast.to_param}, valid_session
      expect(assigns(:forecast)).to eq(forecast)
    end
  end

end
