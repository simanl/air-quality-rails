require "rails_helper"

RSpec.describe ForecastsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get: "/forecasts").to route_to("forecasts#index")
    end

    it "does not route to #new" do
      expect(get: "/forecasts/new").to_not route_to("forecasts#new")
    end

    it "routes to #show" do
      expect(get: "/forecasts/1").to route_to("forecasts#show", id: "1")
    end

    it "does not route to #edit" do
      expect(get: "/forecasts/1/edit").to_not route_to("forecasts#edit", id: "1")
    end

    it "does not route to #create" do
      expect(post: "/forecasts").to_not route_to("forecasts#create")
    end

    it "does not route to #update via PUT" do
      expect(put: "/forecasts/1").to_not route_to("forecasts#update", id: "1")
    end

    it "does not route to #update via PATCH" do
      expect(patch: "/forecasts/1").to_not route_to("forecasts#update", id: "1")
    end

    it "does not route to #destroy" do
      expect(delete: "/forecasts/1").to_not route_to("forecasts#destroy", id: "1")
    end

  end
end
