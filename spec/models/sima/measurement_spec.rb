require "rails_helper"

RSpec.describe Sima::Measurement, type: :model do

  def normal_type_a_response
    @normal_type_a_response ||= File.read(Rails.root.join("spec", "fixtures", "sima_response_type_a.json"))
  end

  def overnight_type_b_response
    @overnight_type_b_response ||= File.read(Rails.root.join("spec", "fixtures", "sima_response_type_b-overnight.json"))
  end

  describe "class methods" do
    subject { described_class }

    describe "Sima::Measurement.pull" do
      let(:type_a_response) { normal_type_a_response }
      let(:type_b_response) { normal_type_b_response }

      before do
        faraday_mock = instance_double "Faraday::Connection"

        allow(faraday_mock).to receive(:get)
          .with("/PollutionServer/")
          .and_return instance_double("Faraday::Response", body: type_a_response)

        allow(faraday_mock).to receive(:get)
          .with("/simaservernlpro/")
          .and_return instance_double("Faraday::Response", body: type_b_response)

        allow(Sima::Measurement).to receive(:conn).and_return faraday_mock
      end

      context "overnight" do
        let(:type_b_response) { overnight_type_b_response }

        it "every measurement has a core set of values" do
          expect(described_class.pull)
            .to all have_attributes imeca_points: be_present,
                                    temperature: be_present,
                                    relative_humidity: be_present,
                                    wind_direction: be_present,
                                    wind_speed: be_present
        end
      end
    end
  end
end
