class Station < ActiveRecord::Base

  validates :code, uniqueness: true
  delegate :latitude, :longitude, to: :lonlat

end
