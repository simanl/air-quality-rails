class PullDataFromSimaJob < ActiveJob::Base
  queue_as :default

  COLLECTABLE_ATTRIBUTES = %w(temperature relative_humidity wind_direction wind_speed
  precipitation atmospheric_pressure solar_radiation carbon_monoxide
  sulfur_dioxide ozone toracic_particles respirable_particles nitrogen_dioxide
  nitric_oxide nitrogen_oxides imeca_points).freeze

  def perform(*args)

    Sima::Measurement.pull.each do |sima_msrmnt|

      # Obtain the refered station from our database, or create it:
      station = Station.find_or_create_by(code: sima_msrmnt.station.code) do |station|
        station.name        = sima_msrmnt.station.name
        station.short_name  = sima_msrmnt.station.short_name
        station.lonlat      = "POINT(#{sima_msrmnt.station.longitude} #{sima_msrmnt.station.latitude})"
      end

      # Add the measurement to the database, only if there's no other measurement
      # for the same 'measured_at' timestamp:
      attrs = COLLECTABLE_ATTRIBUTES.inject({}) do |collected_attrs, attr_name|
        collected_attrs[attr_name] = sima_msrmnt.public_send(attr_name)
        collected_attrs
      end

      station.measurements.create_with(attrs)
        .find_or_create_by(measured_at: sima_msrmnt.measured_at)

    end

  end

end
