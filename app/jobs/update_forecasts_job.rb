require "rserve"
require "rserve/simpler"

class UpdateForecastsJob < ActiveJob::Base
  queue_as :forecasting

  attr_reader :current_dataframe_time_range,
              :next_dataframe_time_range,
              :dataframe_measurements,
              :updated_forecasts_data

  def perform(allow_imputation = true)
    @allow_imputation = allow_imputation

    # Get the dataframe time range for datetime used to generate forecasts:
    @current_dataframe_time_range = Forecast.engine_dataframe_time_range_for last_processed_dataframe_max
      .advance(hours: 1)
      .localtime("-06:00")

    @next_dataframe_time_range = Forecast.engine_dataframe_time_range_for last_processed_dataframe_max
      .advance(hours: 7)
      .localtime("-06:00")

    # Cancel the task if forecasts have already been generated with the given
    # dataframe:
    return if current_dataframe_has_already_been_processed?

    # Cancel the task unless the current_dataframe can be closed with the
    # available measurements:
    return unless current_dataframe_can_be_closed?

    # Get the measurements (including blanks) for the forecast engine:
    @dataframe_measurements = Measurement
      .for_time_range_dataframe current_dataframe_time_range

    # Cancel the task if the measurements include blanks and imputation is not
    # allowed:
    return if dataframe_has_blanks_and_inputation_is_not_allowed?

    input_dataframe = dataframe_measurements.as_forecast_engine_input_dataframe
    engine = ForecastEngine.new
    @updated_forecasts_data = engine.update_forecasts input_dataframe

    # Upsert the forecasts into the database:
    upsert_updated_forecasts_data!

    # Stop unless measurements exist beyond the next dataframe's time range:
    enqueue_next_update_if_next_dataframe_can_be_closed!
  end

  private

    def upsert_updated_forecasts_data!
      # A dictionary of stations indexed by short_name:
      station_dictionary = Station.forecastable.inject({}) do |list, station|
        list.merge(station.short_name => station)
      end

      @updated_forecasts_data.inject({}) do |grouped_data, fd|
        # Merge pollutant quality forecasts by station and starts_at datetime:
        station = station_dictionary[fd[:site]]
        group_key = [station, fd[:start_at]]

        grouped_data[group_key] = {
          ends_at: fd[:end_at],
          last_dataframe_ended_at: current_dataframe_time_range.max
        } unless grouped_data.key?(group_key)

        grouped_data[group_key]["#{fd[:pollutant]}_index".to_sym] = fd[:index]
        grouped_data[group_key]["#{fd[:pollutant]}_category".to_sym] = fd[:category]
        grouped_data
      end.each do |station_starts_at_attributes|
        station_forecast_starts_at, forecast_attributes = station_starts_at_attributes
        station, forecast_starts_at = station_forecast_starts_at

        forecast = station.forecasts.find_or_initialize_by starts_at: forecast_starts_at
        forecast.assign_attributes forecast_attributes
        forecast.save # Si no se guardó, se chingó - no se puede volver a mandar al engine...
      end
    end

    def current_dataframe_can_be_closed?
      Measurement.dataframe_for_time_range_can_be_closed? current_dataframe_time_range
    end

    def next_dataframe_can_be_closed?
      Measurement.dataframe_for_time_range_can_be_closed? next_dataframe_time_range
    end

    def imputation_allowed?
      @allow_imputation == true
    end

    def last_processed_dataframe_max
      # Get the last dataframe time range max recorded in the forecasts table:
      fetched_last_dataframe_max = Forecast.maximum(:last_dataframe_ended_at)
      return fetched_last_dataframe_max if fetched_last_dataframe_max.present?

      # If no last dataframe max was fetched from our database, we'll assume it is
      # the earliest measurement datetime from the available importable cycles:
      Time.parse("2016-04-30T23:00:00.00-06:00")
    end

    def current_dataframe_has_already_been_processed?
      return false unless Forecast.updated_from_time_range(current_dataframe_time_range).any?
      logger.info "Forecasts have already been generated for the resulting dataframe"
      true
    end

    def dataframe_has_blanks_and_inputation_is_not_allowed?
      return false if dataframe_measurements.has_no_blank_measurements? || imputation_allowed?
      logger.warn "Input data does not look complete..."
      true
    end

    def enqueue_next_update_if_next_dataframe_can_be_closed!
      return unless next_dataframe_can_be_closed?
      logger.info "Next dataframe looks ready - Enqueing the next forecast update."
      self.class.perform_later imputation_allowed?
    end
end
