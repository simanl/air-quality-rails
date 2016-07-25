class Measurement < ActiveRecord::Base
  WIND_CARDINALITY_MAPPING = {
    0..23  => "north",
    24..68 => "northeast",
    69..113 => "east",
    114..158 => "southeast",
    159..203 => "south",
    204..248 => "southwest",
    249..293 => "west",
    294..338 => "northwest",
    339..360 => "north"
  }.freeze

  IMECA_CATEGORY_MAPPING = {
    0..50 => "good",
    50..100 => "regular",
    101..150 => "bad",
    151..200 => "very_bad",
    201..Float::INFINITY => "extremely_bad"
  }.freeze

  belongs_to :station, required: true

  store_accessor :weather,
    :atmospheric_pressure,
    :precipitation,
    :relative_humidity, # Percentage Points (0..100)
    :solar_radiation,
    :temperature,
    :wind_direction,
    :wind_speed

  store_accessor :pollutants,
    :carbon_monoxide,
    :nitric_oxide,
    :nitrogen_dioxide,
    :nitrogen_oxides, # https://en.wikipedia.org/wiki/Nitrogen_oxide
    :ozone,
    :sulfur_dioxide,
    # Both Toracic (PM > 10nm) and Respirable (PM > 2.5 nm) are Inhalable Particles:
    :toracic_particles,   # PM10
    :respirable_particles # PM2.5

  validates :measured_at,
    presence: true,
    uniqueness: { scope: :station, message: "already exists for station" }

  validates :wind_direction,
    numericality: { greater_than_or_equal_to: 0, less_than: 360 },
    allow_nil: true

  after_create :update_station_last_measurement!

  scope :after, -> (timestamp) { where arel_table[:measured_at].gt(timestamp) }
  scope :since, -> (timestamp) { where arel_table[:measured_at].gteq(timestamp) }
  scope :measured_within, -> (time_range) { where measured_at: time_range }
  scope :blank_measurements, -> { where arel_table[:id].eq(nil) }
  scope :grouped_by_station, -> { group :station_id }

  def wind_cardinal_direction
    mapped_value WIND_CARDINALITY_MAPPING, :wind_direction
  end

  def imeca_category
    mapped_value IMECA_CATEGORY_MAPPING, :imeca_points
  end

  def mapped_value(mappings, reader)
    mappings.reduce(nil) do |found_value, mapping|
      range, value = mapping
      range.cover?(public_send(reader)) ? value : found_value
    end if public_send(reader).present?
  end

  class << self
    # Operations over scopes: ==================================================
    def has_blank_measurements?
      blank_measurements.any?
    end

    def has_no_blank_measurements?
      blank_measurements.empty?
    end

    def dataframe_for_time_range_can_be_closed?(given_time_range)
      since(given_time_range.max).any?
    end

    # Complex scopes: ==========================================================
    def latest
      sub_query = Measurement.latest_grouped.arel.as '"grouping"'
      join_query = arel_table.join(sub_query).on(
        arel_table[:station_id].eq(sub_query[:station_id]).and(
          arel_table[:updated_at].eq sub_query[:updated_at]
        )
      )
      joins(join_query.join_sources)
    end

    # The query used internally that selects the latest ones:
    def latest_grouped
      # We're using unscoped to prevent `station.measurement.latest` trying to
      # allocate two parameters whereas just providing one (station_id).
      # TODO: Try any way to make this work without `unscoped`, since it would be
      # better to be able to also filter this nested query...
      unscoped.select(
        :station_id,
        Arel::Nodes::NamedFunction.new("max", [arel_table[:updated_at]]).as('"updated_at"')
      ).group(:station_id)
    end

    # Gets a list of measurements for all the 'forecastable' stations for each
    # hour withing the given time range, filling missing measurements with blank
    # measurement objects, so we can feed the forecast engine with the data it
    # expects to trigger data imputation...
    def for_time_range_dataframe(time_range)
      # Get the complex subquery aliased as 'base_dataframe':
      base_df_subquery = Station.dataframe_for_time_range(time_range)
                                .as "\"base_dataframe\""

      # Create the join conditions between the measurements table and the subquery:
      join_condition = arel_table[:station_id]
        .eq(base_df_subquery[:station_id])
        .and(arel_table[:measured_at].eq(base_df_subquery[:measured_at]))

      joins arel_table.create_join(
        base_df_subquery,
        base_df_subquery.create_on(join_condition),
        Arel::Nodes::RightOuterJoin
      )
    end

    # Selects the columns to generate the forecast engine input dataframe:
    def as_forecast_engine_input_dataframe
      # A reference to the complex subquery aliased as 'base_dataframe':
      base_df_subquery = Arel::Table.new :base_dataframe

      order(base_df_subquery[:station_id].asc, base_df_subquery[:measured_at].asc)
        .includes(:station)
        .select arel_table[:id],
                base_df_subquery[:station_id],
                base_df_subquery[:measured_at],
                arel_table[:weather],
                arel_table[:pollutants],
                arel_table[:imeca_points],
                arel_table[:created_at],
                arel_table[:updated_at]
    end

    def last_for_each_station
      # Get the subquery aliased as 'base_dataframe':
      last_measurements = last_for_each_station_subquery
        .as("\"last_measurements\"")

      # Create the join conditions between the measurements table and the subquery:
      join_condition = arel_table[:station_id]
        .eq(last_measurements[:station_id])
        .and(arel_table[:measured_at].gteq(last_measurements[:measured_at]))

      joins arel_table.create_join(
        last_measurements,
        last_measurements.create_on(join_condition),
        Arel::Nodes::InnerJoin
      )
    end

    private

      def last_for_each_station_subquery
        last_measured_at = Arel::Nodes::Max.new [arel_table[:measured_at]]
        grouped_by_station.select arel_table[:station_id],
                                  last_measured_at.as("\"measured_at\"")
      end
  end

  protected

    def update_station_last_measurement!
      station.update last_measurement_id: station.measurements.latest
        .limit(1).pluck(:id).first
    end
end
