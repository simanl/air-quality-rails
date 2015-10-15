require "rserve"
require "rserve/simpler"

class UpdateForecastsJob < ActiveJob::Base
  queue_as :forecasting

  def perform(*args)

    active_stations = Station.active

    # Get the 'measured_at' timestamp from the last measurements used in the
    # forecast update process:
    last_processed_dt = Measurement.joins(:forecasts).maximum(:measured_at)

    last_processed_dt = Time.parse('2014-06-01T00:00:00.00-06:00')
      .advance(hours: -1) unless last_processed_dt.present?

    start_dt = last_processed_dt.advance(hours: 1)
    finish_dt = start_dt.advance(hours: 5)

    measurements_to_process = Measurement.includes(:station).joins(:station)
      .merge(active_stations)
      .where(measured_at: start_dt..finish_dt)
      .order(station_id: :asc, measured_at: :asc)

    # Cancel the task if the dataframe cannot_be_completed not complete:
    unless input_data_looks_complete?(measurements_to_process)
      puts "Input data does not look complete..."
      return
    end

    engine = ForecastEngine.new
    forecast_data = engine.update_forecasts(measurements_to_process)

    # A dictionary of stations indexed by short_name:
    active_stations_dictionary = Station.active.inject({}) do |list, station|
      list.merge(station.short_name => station)
    end

    # Upsert the forecasts into the database:
    forecast_data.inject({}) do |grouped_data, fd|
      # Merge pollutant quality forecasts by station and starts_at datetime:
      station = active_stations_dictionary[fd[:site]]
      group_key = [station, fd[:start_at]]

      grouped_data[group_key] = {
        'ends_at' => fd[:end_at],
        'measurements' => measurements_to_process.to_a.select { |x| x.station == station }
      } unless grouped_data.key?(group_key)

      grouped_data[group_key][fd[:pollutant]] = fd[:quality]
      grouped_data
    end.each do |station_starts_at, attributes|
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
      # currently active 5 stations:
      counts.keys.size == 5 && counts.values.uniq == [6]
    end

    delegate :input_data_looks_complete?, to: :class
end