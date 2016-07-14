module Sima
  class Measurement
    include ActiveModel::Model

    # General:
    attr_accessor :station, :measured_at, :imeca_points

    # Weather:
    attr_accessor :atmospheric_pressure,
                  :precipitation,
                  :relative_humidity, # Percentage Points (0..100)
                  :solar_radiation,
                  :temperature,
                  :wind_direction,
                  :wind_speed

    # Pollutants:
    attr_accessor :carbon_monoxide,
                  :nitric_oxide,
                  :nitrogen_dioxide,
                  :nitrogen_oxides, # https://en.wikipedia.org/wiki/Nitrogen_oxide
                  :ozone,
                  :sulfur_dioxide,
                  # Both Toracic (PM > 10nm) and Respirable (PM > 2.5 nm) are Inhalable Particles:
                  :toracic_particles,   # PM10
                  :respirable_particles # PM2.5

    class << self
      def conn
        @conn ||= Faraday.new(url: 'http://ecolaboracion.nl.gob.mx') do |c|
          # c.request  :url_encoded             # form-encode POST params
          # c.response :logger                  # log requests to STDOUT
          c.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end
      end

      def pull
        # Pull general data:
        # TODO: use only the 2nd request to generate data, as soon as the extra
        # data needed is available on the second request:
        msrmnts = fetch_type_a

        fetch_type_b.each do |type_b_msrmnt|
          if (msrmnt = msrmnts.detect { |x| x.station.code == type_b_msrmnt.station.code })
            %w(temperature relative_humidity wind_direction wind_speed
            precipitation atmospheric_pressure solar_radiation carbon_monoxide
            sulfur_dioxide ozone toracic_particles respirable_particles
            nitrogen_dioxide nitric_oxide nitrogen_oxides).each do |attr_name|
              msrmnt.public_send "#{attr_name}=", type_b_msrmnt.public_send(attr_name)
            end
          else
            msrmnts << type_b_msrmnt
          end
        end

        msrmnts
      end

      protected

        def parse_fetch_of_type(fetched_data, fetch_type = :type_a)
          general_station_attributes = extract_general_station_attributes fetched_data
          general_measurement_attributes = extract_general_measurement_attributes fetched_data
          parse_method = "from_#{fetch_type}_data".to_sym

          fetched_data['pollutionMeasurements']['Stations'].map do |measurement_data|
            parsed_measurement = send parse_method,
                                      measurement_data,
                                      general_measurement_attributes

            parsed_measurement.station = Sima::Station.send parse_method,
                                                            measurement_data,
                                                            general_station_attributes

            parsed_measurement
          end
        end

        def fetch_type_a
          parse_fetch_of_type ActiveSupport::JSON.decode(conn.get('/PollutionServer/').body),
                              :type_a
        end

        def from_type_a_data(measurement, general_attributes = {})
          self.new general_attributes.merge(
            imeca_points: measurement['imecaPoints'],
            temperature:  measurement['temperature'],

            # Convert to percentage points:
            relative_humidity: measurement['humidity'] * 100,

            wind_direction: measurement['windDirection'],
            wind_speed:     measurement['windSpeed']
          )
        end

        def fetch_type_b
          parse_fetch_of_type ActiveSupport::JSON.decode(conn.get('/simaservernlpro/').body),
                              :type_b
        end

        def from_type_b_data(data, general_attributes = {})
          self.new general_attributes.merge(
            temperature:          normalize_numeric_value(data['TOUT']),
            relative_humidity:    normalize_numeric_value(data['HR']),
            wind_direction:       normalize_numeric_value(data['WDR']),
            wind_speed:           normalize_numeric_value(data['WS']),
            precipitation:        normalize_numeric_value(data['RAINF']),
            atmospheric_pressure: normalize_numeric_value(data['PRS']),
            solar_radiation:      normalize_numeric_value(data['SR']),

            carbon_monoxide:      normalize_numeric_value(data['CO']),
            sulfur_dioxide:       normalize_numeric_value(data['SO2']),
            ozone:                normalize_numeric_value(data['O3']),
            toracic_particles:    normalize_numeric_value(data['PM10']),
            respirable_particles: normalize_numeric_value(data['PM25']), # It's actually "PM2.5", not "PM25"
            nitrogen_dioxide:     normalize_numeric_value(data['NO2']),
            nitric_oxide:         normalize_numeric_value(data['NO']),
            nitrogen_oxides:      normalize_numeric_value(data['NOX'])
          )
        end

        def extract_general_station_attributes(data)
          {
            city: data['pollutionMeasurements']['City'],
            city_code: data['pollutionMeasurements']['CityCode'],
            country: data['pollutionMeasurements']['Country'],
            agency: data['pollutionMeasurements']['MeasurementAgency'],
            url: data['pollutionMeasurements']['URL']
          }
        end

        def extract_general_measurement_attributes(data)
          { measured_at: DateTime.parse(data['pollutionMeasurements']['TimeStamp']) }
        end

        def normalize_numeric_value(given_value)
          given_value.present? ? given_value.to_f : nil
        end
    end
  end
end
