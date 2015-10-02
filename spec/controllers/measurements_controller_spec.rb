require 'rails_helper'

RSpec.describe MeasurementsController, type: :controller do

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # MeasurementsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all measurements as @measurements" do
      measurement = Measurement.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:measurements)).to eq([measurement])
    end
  end

  describe "GET #show" do
    it "assigns the requested measurement as @measurement" do
      measurement = Measurement.create! valid_attributes
      get :show, {:id => measurement.to_param}, valid_session
      expect(assigns(:measurement)).to eq(measurement)
    end
  end

end
