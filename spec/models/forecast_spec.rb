require 'rails_helper'

RSpec.describe Forecast, type: :model do

  # Check the availability of persisted properties:
  describe "attributes" do
    it { is_expected.to have_attributes station: a_value }
    it { is_expected.to have_attributes forecasted_datetime: nil }
  end

  describe "validity" do
    context "with a missing station" do
      subject { build :forecast, station: nil }
      it { is_expected.to_not be_valid }
    end

    context "with a missing forecasted_datetime datetime" do
      subject { build :forecast, forecasted_datetime: nil }
      it { is_expected.to_not be_valid }
    end

    context "with no forecasted parameters" do
      subject { build :forecast, ozone: nil, toracic_particles: nil, respirable_particles: nil }
      it { is_expected.to_not be_valid }
    end
  end

end
