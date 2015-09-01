require 'rails_helper'

RSpec.describe Station, type: :model do

  # Check the availability of persisted properties:
  describe "attributes" do
    it { is_expected.to respond_to :code }
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :short_name }
    it { is_expected.to respond_to :lonlat }
  end

  # Check the availability of computed properties:
  describe "computed properties" do
    it { is_expected.to respond_to :latitude }
    it { is_expected.to respond_to :longitude }
  end

  # Check the availability of associations:
  describe "associations", wip: true do
    it { is_expected.to respond_to :measurements }
    it { is_expected.to respond_to :last_measurement }
  end

end
