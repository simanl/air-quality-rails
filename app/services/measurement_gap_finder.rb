class MeasurementGapFinder
  def found_gaps
    @found_gaps ||= self.measurement_gaps
  end

  def self.find_gaps(options = nil)
    stations = Station.order(id: :asc)
    if options.present?
      stations = stations.where(is_forecastable: true) if options[:for_forecastable_stations_only]
    end

    station_ids = stations.pluck :id

    stations_last_measured_at = station_ids.reduce({}) do |dict, station_id|
      dict[station_id] = nil
      dict
    end

    stations_measurement_gaps = station_ids.reduce({}) do |dict, station_id|
      dict[station_id] = []
      dict
    end

    measurements = Measurement.joins(:station).merge(stations)
      .select(:id, :station_id, :measured_at)

    measurements.find_each(batch_size: 2000) do |measurement|
      station_id = measurement.station_id
      measured_at = measurement.measured_at

      last_measurement_at = stations_last_measured_at[station_id]

      stations_measurement_gaps[station_id] << (last_measurement_at..measured_at) \
        if last_measurement_at && measured_at != last_measurement_at.advance(hours: 1)

      stations_last_measured_at[station_id] = measured_at
    end

    stations_measurement_gaps
  end
end
