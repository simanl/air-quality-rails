require "rails_helper"

RSpec.describe Sima::Measurement, type: :model do
  describe "class methods" do
    subject { described_class }

    describe "Sima::Measurement.pull" do
      let(:mock_response_pair) { SimaMock.ideal_scenario }

      before do
        faraday_mock = instance_double "Faraday::Connection"

        allow(faraday_mock).to receive(:get)
          .with("/PollutionServer/")
          .and_return instance_double("Faraday::Response", body: mock_response_pair.response_a)

        allow(faraday_mock).to receive(:get)
          .with("/simaservernlpro/")
          .and_return instance_double("Faraday::Response", body: mock_response_pair.response_b)

        allow(Sima::Measurement).to receive(:conn).and_return faraday_mock
      end

      context "when both sima responses respond with ideal responses" do
        let(:mock_response_pair) { SimaMock.ideal_scenario }

        it "returns only one measurement for each station", skip: true do
          measurements_grouped_by_station = described_class.pull.group_by :station
          # expect
        end

        it "every measurement has the expected values", skip: true do
          expect(described_class.pull)
            .to all have_attributes station: be_present,
                                    measured_at: be_present,
                                    imeca_points: be_present,
                                    atmospheric_pressure: be_present,
                                    precipitation: be_present,
                                    relative_humidity: be_present,
                                    solar_radiation: be_present,
                                    temperature: be_present,
                                    wind_direction: be_present,
                                    wind_speed: be_present,
                                    carbon_monoxide: be_present,
                                    nitric_oxide: be_present,
                                    nitrogen_dioxide: be_present,
                                    nitrogen_oxides: be_present,
                                    ozone: be_present,
                                    sulfur_dioxide: be_present,
                                    toracic_particles: be_present,
                                    respirable_particles: be_present
        end
      end

      context "when measurements on both sima responses have the same timestamps" do

      end

      context "when measurements on both sima responses have different timestamps" do

      end
    end
  end
end
