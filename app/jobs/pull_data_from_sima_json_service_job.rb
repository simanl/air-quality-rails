class PullDataFromSimaJsonServiceJob < ActiveJob::Base
  queue_as :default

  # A list of station code mappings used to rename station codes from names that
  # deviate from the established standard:
  STATION_CODES_CLEANING = {
    "suroeste2-san-pedro" => "suroeste-2-san-pedro"
  }

  def perform(*args)
    # Do something later

    # Obtain a response from the provisional service:
    conn = Faraday.new(url: 'http://ecolaboracion.nl.gob.mx') do |c|
      # c.request  :url_encoded             # form-encode POST params
      # c.response :logger                  # log requests to STDOUT
      c.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    response = conn.get '/PollutionServer/'

    response_data = ActiveSupport::JSON.decode response.body

    # Unfortunately, the provisional Govt. API does not expose the measurement
    # timestamp individually, so we must assume all measurements in the response
    # were made at the same times as the parent object's timestamp:
    measurements_timestamp = \
      DateTime.parse response_data['pollutionMeasurements']['TimeStamp']

    # Walk through the "station" list to update our data:
    response_data['pollutionMeasurements']['Stations'].each do |station_data|
      station_code = station_data['name'].split.map(&:downcase).join('-')
      station_code = STATION_CODES_CLEANING[station_code] if STATION_CODES_CLEANING.key? station_code

      # Obtain the refered station from our database, or create it:
      station = Station.find_or_create_by(code: station_code) do |station|
        station.name        = station_data['name'].titleize
        station.short_name  = station_data['shortName'].titleize

        latitude, longitude = station_data['location'].split(',')
        station.lonlat      = "POINT(#{longitude} #{latitude})"
      end

      # Add the measurement to the database, only if there's no other measurement
      # for the same 'measured_at' timestamp:
      station.measurements.create_with(
        temperature:       station_data['temperature'],
        relative_humidity: station_data['humidity'],
        wind_direction:    station_data['windDirection'],
        wind_speed:        station_data['windSpeed'],
        imeca_points:      station_data['imecaPoints']
      ).find_or_create_by(measured_at: measurements_timestamp)

    end

  end
end
