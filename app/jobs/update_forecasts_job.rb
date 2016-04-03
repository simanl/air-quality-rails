require "rserve"
require "rserve/simpler"

class UpdateForecastsJob < ActiveJob::Base
  queue_as :forecasting

  def perform(allow_imputation = false)
    forecastable_stations = Station.forecastable

    # Get the 'measured_at' timestamp from the last measurements used in the
    # forecast update process:
    last_processed_dt = Measurement.joins(:forecasts).maximum(:measured_at)

    # If there were no previous forecasts... let's get the earliest registered
    # measurement's datetime, and set 'last_processed_dt' to 1 hour before said
    # measurement:
    last_processed_dt = Measurement.minimum(:measured_at)
      .advance(hours: -1) unless last_processed_dt.present?

    # If there's still no datetime were no previous forecasts... let's get the
    # earliest measurement datetime from the available importable cycles:
    last_processed_dt = Time.parse('2014-06-01T00:00:00.00-06:00')
      .advance(hours: -1) unless last_processed_dt.present?

    start_dt = last_processed_dt.advance(hours: 1)
    finish_dt = start_dt.advance(hours: 5)

    # Stop if we know up to this point that there shouldn't be enough measurements:
    if Time.now < finish_dt
      logger.info "There should't be enough measurements yet..."
      return
    end

    measurements_to_process = Measurement.includes(:station)
      .forecast_engine_dataframe(start_dt)

    # Cancel the task if the dataframe cannot_be_completed not complete:
    unless input_data_looks_complete?(measurements_to_process) || allow_imputation
      logger.warn "Input data does not look complete..."
      return
    end

    engine = ForecastEngine.new
    forecast_data = engine.update_forecasts(measurements_to_process)

    # A dictionary of stations indexed by short_name:
    forecastable_stations_dictionary = Station.forecastable.inject({}) do |list, station|
      list.merge(station.short_name => station)
    end

    # Upsert the forecasts into the database:
    forecast_data.inject({}) do |grouped_data, fd|
      # Merge pollutant quality forecasts by station and starts_at datetime:
      station = forecastable_stations_dictionary[fd[:site]]
      group_key = [station, fd[:start_at]]

      grouped_data[group_key] = {
        'ends_at' => fd[:end_at],
        'measurements' => measurements_to_process.to_a.select { |x| x.station == station }
      } unless grouped_data.key?(group_key)
      grouped_data[group_key]["#{fd[:pollutant]}_index".to_sym] = fd[:index]
      grouped_data[group_key]["#{fd[:pollutant]}_category".to_sym] = fd[:category]
      grouped_data
    end.inject({}) do |dict, station_starts_at_attributes|
      station_starts_at, attributes = station_starts_at_attributes
      station, starts_at = station_starts_at
      forecast = station.forecasts.find_or_initialize_by(starts_at: starts_at)
      attributes.each do |name, value|
        if name == 'measurements'
          forecast.measurements += value
        else
          forecast.send("#{name}=", value)
        end
      end
      forecast.save!

      # add the forecast id to the stations dictionary:
      dict[station] = [] unless dict.key?(station)
      dict[station] << forecast.id
      dict
    end.each do |station, forecast_ids|
      station.update current_forecast_ids: forecast_ids
    end

    # Enqueue the next update right away, if there's enough data to do it:
    if input_data_looks_complete?(Measurement.forecast_engine_dataframe finish_dt.advance(hours: 1))
      logger.info "There are enough measurements available to call the forecast update again..."
      self.class.perform_later(allow_imputation)
    end
  end

  private

    def self.input_data_looks_complete?(measurements)
      counts = measurements.map(&:station_id).inject({}) do |counts, station_id|
        counts[station_id] = 0 unless counts.key?(station_id)
        counts[station_id] += 1
        counts
      end

      # Currently, there should be 6 measurements by each station, from the
      # 5 currently forecastable stations:
      counts.keys.size == 5 && counts.values.uniq == [6]
    end

    delegate :input_data_looks_complete?, to: :class
end
