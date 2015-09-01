require 'rails_helper'

RSpec.describe Measurement, type: :model do

  describe 'class' do
    subject { described_class }

    it { is_expected.to respond_to :since }

    describe ".since" do
      it "retrieves measurements since a given datetime"
    end
  end

  # Check the availability of persisted properties:
  describe "attributes" do
    it { is_expected.to respond_to :station_id }
    it { is_expected.to respond_to :measured_at }
    it { is_expected.to respond_to :temperature }
    it { is_expected.to respond_to :relative_humidity }
    it { is_expected.to respond_to :wind_speed }
    it { is_expected.to respond_to :wind_direction }
    it { is_expected.to respond_to :imeca_points }
  end

  # Check the availability of computed properties:
  describe "computed properties" do
    it { is_expected.to respond_to :wind_cardinal_direction }
    it { is_expected.to respond_to :imeca_category }

    describe "#imeca_category (IMECA categorization)" do
      # Sources:
      # https://en.wikipedia.org/wiki/%C3%8Dndice_Metropolitano_de_la_Calidad_del_Aire

      context "when the measured IMECA index is between 0 and 50" do
        subject { build(:measurement, imeca_points: 25).imeca_category }
        it { is_expected.to eq 'good' }
      end

      context "when the measured IMECA index is between 51 and 100" do
        subject { build(:measurement, imeca_points: 75).imeca_category }
        it { is_expected.to eq 'regular' }
      end

      context "when the measured IMECA index is between 101 and 150" do
        subject { build(:measurement, imeca_points: 125).imeca_category }
        it { is_expected.to eq 'bad' }
      end

      context "when the measured IMECA index is between 151 and 200" do
        subject { build(:measurement, imeca_points: 175).imeca_category }
        it { is_expected.to eq 'very_bad' }
      end

      context "when the measured IMECA index is above 200" do
        subject { build(:measurement, imeca_points: 201).imeca_category }
        it { is_expected.to eq 'extremely_bad' }
      end

      context "when there's no measured IMECA index" do
        subject { build(:measurement, imeca_points: nil).imeca_category }
        it { is_expected.to eq nil }
      end

    end

    describe "#wind_cardinal_direction" do
      # Sources:
      # https://en.wikipedia.org/wiki/Cardinal_direction

      context "when the measured wind direction is between 339 to 360 degrees" do
        subject { build(:measurement, wind_direction: 350).wind_cardinal_direction }
        it { is_expected.to eq 'north' }
      end

      context "when the measured wind direction is between 1 to 23 degrees" do
        subject { build(:measurement, wind_direction: 11).wind_cardinal_direction }
        it { is_expected.to eq 'north' }
      end

      context "when the measured wind direction is between 24 to 68 degrees" do
        subject { build(:measurement, wind_direction: 45).wind_cardinal_direction }
        it { is_expected.to eq 'northeast' }
      end

      context "when the measured wind direction is between 69 to 113 degrees" do
        subject { build(:measurement, wind_direction: 90).wind_cardinal_direction }
        it { is_expected.to eq 'east' }
      end

      context "when the measured wind direction is between 114 to 158 degrees" do
        subject { build(:measurement, wind_direction: 125).wind_cardinal_direction }
        it { is_expected.to eq 'southeast' }
      end

      context "when the measured wind direction is between 159 to 203 degrees" do
        subject { build(:measurement, wind_direction: 180).wind_cardinal_direction }
        it { is_expected.to eq 'south' }
      end

      context "when the measured wind direction is between 204 to 248 degrees" do
        subject { build(:measurement, wind_direction: 225).wind_cardinal_direction }
        it { is_expected.to eq 'southwest' }
      end

      context "when the measured wind direction is between 249 to 293 degrees" do
        subject { build(:measurement, wind_direction: 270).wind_cardinal_direction }
        it { is_expected.to eq 'west' }
      end

      context "when the measured wind direction is between 294 to 338 degrees" do
        subject { build(:measurement, wind_direction: 315).wind_cardinal_direction }
        it { is_expected.to eq 'northwest' }
      end

      context "when there's no measured wind direction" do
        subject { build(:measurement, wind_direction: nil).wind_cardinal_direction }
        it { is_expected.to eq nil }
      end

    end
  end

  # Check the availability of associations:
  # Check the availability of associations:
  describe "associations" do
    it { is_expected.to respond_to :station }
  end

end
