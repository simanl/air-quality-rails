class Station < ActiveRecord::Base

  validates :code, uniqueness: true
  delegate :latitude, :longitude, to: :lonlat

  has_many :measurements
  belongs_to :last_measurement, class_name: "Measurement"

  has_many :forecasts
  has_many :current_forecasts, -> { current.limit(6) },
    class_name: "Forecast"

  # params:
  # a) latitude, longitude
  # b) "lat,lon" as String
  def self.nearest_from(*args)

    ref_lat, ref_lon = if args[0].respond_to? :round
      # First argument is numeric, so we're expecting an x,y coordinates:

      # Raise an argument exception if 'y' is not numeric:
      raise ArgumentException unless args[1].respond_to? :round

      args
    elsif args[0].respond_to? :split
      # most probably a string which we should split from a comma:
      args[0].split(',').map { |n| BigDecimal.new n }
    else
      raise ArgumentException
    end

    # TODO: ARel-ize this!
    # TODO: Validate results...
    order("ST_Distance(lonlat, ST_GeogFromText('SRID=4326;POINT(#{ref_lon} #{ref_lat})'))")

  end

end
