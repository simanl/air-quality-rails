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
    it { is_expected.to have_attributes station: a_value }
    it { is_expected.to have_attributes measured_at: nil }
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

      it "is 'good' when the measured IMECA index is between 0 and 50" do
        expect(
          build(:measurement, imeca_points: 25).imeca_category
        ).to eq 'good'
      end

      it "is 'regular' when the measured IMECA index is between 51 and 100" do
        expect(
          build(:measurement, imeca_points: 75).imeca_category
        ).to eq 'regular'
      end

      it "is 'bad' when the measured IMECA index is between 101 and 150" do
        expect(
          build(:measurement, imeca_points: 125).imeca_category
        ).to eq 'bad'
      end

      it "is 'very_bad' when the measured IMECA index is between 151 and 200" do
        expect(
          build(:measurement, imeca_points: 175).imeca_category
        ).to eq 'very_bad'
      end

      it "is 'extremely_bad' when the measured IMECA index is above 200" do
        expect(
          build(:measurement, imeca_points: 201).imeca_category
        ).to eq 'extremely_bad'
      end

      it "is nil when there's no measured IMECA index" do
        expect(
          build(:measurement, imeca_points: nil).imeca_category
        ).to eq nil
      end

    end

    describe "#wind_cardinal_direction" do
      # Sources:
      # https://en.wikipedia.org/wiki/Cardinal_direction

      it "is 'north' when wind direction is between 339 to 360 degrees" do
        expect(
          build(:measurement, wind_direction: 350).wind_cardinal_direction
        ).to eq 'north'
      end

      it "is 'north' when wind direction is between 1 to 23 degrees" do
        expect(
          build(:measurement, wind_direction: 11).wind_cardinal_direction
        ).to eq 'north'
      end

      it "is 'northeast' when wind direction is between 24 to 68 degrees" do
        expect(
          build(:measurement, wind_direction: 45).wind_cardinal_direction
        ).to eq 'northeast'
      end

      it "is 'east' when wind direction is between 69 to 113 degrees" do
        expect(
          build(:measurement, wind_direction: 90).wind_cardinal_direction
        ).to eq 'east'
      end

      it "is 'southeast' when wind direction is between 114 to 158 degrees" do
        expect(
          build(:measurement, wind_direction: 125).wind_cardinal_direction
        ).to eq 'southeast'
      end

      it "is 'south' when wind direction is between 159 to 203 degrees" do
        expect(
          build(:measurement, wind_direction: 180).wind_cardinal_direction
        ).to eq 'south'
      end

      it "is 'southwest' when wind direction is between 204 to 248 degrees" do
        expect(
          build(:measurement, wind_direction: 225).wind_cardinal_direction
        ).to eq 'southwest'
      end

      it "is 'west' when wind direction is between 249 to 293 degrees" do
        expect(
          build(:measurement, wind_direction: 270).wind_cardinal_direction
        ).to eq 'west'
      end

      it "is 'northwest' when wind direction is between 294 to 338 degrees" do
        expect(
          build(:measurement, wind_direction: 315).wind_cardinal_direction
        ).to eq 'northwest'
      end

      it "is nil when there's no measured wind direction" do
        expect(
          build(:measurement, wind_direction: nil).wind_cardinal_direction
        ).to eq nil
      end

    end
  end

  describe "validity" do
    context "with a missing station" do
      subject { build :measurement, station: nil }
      it { is_expected.to_not be_valid }
    end

    context "with a missing measurement datetime" do
      subject { build :measurement, measured_at: nil }
      it { is_expected.to_not be_valid }
    end
  end

end
