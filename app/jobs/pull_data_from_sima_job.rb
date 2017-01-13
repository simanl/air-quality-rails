class PullDataFromSimaJob < ActiveJob::Base
  queue_as :default

  COLLECTABLE_ATTRIBUTES = %w(temperature relative_humidity wind_direction wind_speed
  precipitation atmospheric_pressure solar_radiation carbon_monoxide
  sulfur_dioxide ozone toracic_particles respirable_particles nitrogen_dioxide
  nitric_oxide nitrogen_oxides imeca_points).freeze

  def perform(*_args)
    measurement_ids = []

    Sima::Measurement.pull.each do |sima_msrmnt|
      # Obtain the refered station from our database, or create it:
      station = Station.find_or_create_by(code: sima_msrmnt.station.code) do |station_to_create|
        station_to_create.assign_attributes(
          name: sima_msrmnt.station.name,
          short_name: sima_msrmnt.station.short_name,
          lonlat: Station.point(sima_msrmnt.station.latitude, sima_msrmnt.station.longitude).to_s
        )
      end

      # Add the measurement to the database, only if there's no other measurement
      # for the same 'measured_at' timestamp:
      attrs = COLLECTABLE_ATTRIBUTES.inject({}) do |collected_attrs, attr_name|
        collected_attrs[attr_name] = sima_msrmnt.public_send(attr_name)
        collected_attrs
      end

      # Define the update-or-create condition:
      measured_at_condition = { measured_at: sima_msrmnt.measured_at }

      # Update the matching measurement if there's any, or create a new measurement:
      # NOTE: In rails 4.2.x, there's no ActiveRecord::Relation.update(attrs) method with this exact
      # signature, but it does exist on rails 5.0.x... hence we'll need to fetch the record and
      # update it:
      if station.measurements.where(measured_at_condition).any?
        measurement = station.measurements.find_by(measured_at_condition)
        measurement.update attrs
      else
        measurement = station.measurements.create attrs.merge(measured_at_condition)
      end

      measurement_ids << measurement.id
    end

    # Update 'most_recent' columns by force... something is not right with the Measurement callbacks
    Measurement.most_recent.where.not(id: measurement_ids).update_all most_recent: false
    Measurement.where(id: measurement_ids).update_all most_recent: true

    enqueue_forecasts_update_if_a_dataframe_can_be_closed!
  end

  protected

    def enqueue_forecasts_update_if_a_dataframe_can_be_closed!
      time_range = Forecast.engine_dataframe_time_range_for(
        Forecast.maximum(:last_dataframe_ended_at) || Time.parse("2016-04-30T23:00:00.00-06:00")
      )
      return unless Measurement.dataframe_for_time_range_can_be_closed? time_range
      logger.info "Current dataframe looks ready - Enqueing a forecast update."
      UpdateForecastsJob.perform_later
    end
end
