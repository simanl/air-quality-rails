class Station < ActiveRecord::Base

  validates :code, uniqueness: true
  delegate :latitude, :longitude, to: :lonlat

  has_many :measurements
  # belongs_to :last_measurement, class_name: "Measurement"
  has_one :last_measurement, -> { last_for_each_station }, class_name: "Measurement"

  has_many :forecasts
  has_many :current_forecasts, -> { last_forecasted_24_hours }, class_name: "Forecast"

  scope :forecastable, -> { where arel_table[:is_forecastable].eq(true) }

  def is_forecastable?
    is_forecastable
  end

  class << self
    # Special/Complex ActiveRecord Scopes: =====================================

    # Returns the current scope as a cartesian product (permutation) between
    # the stations tracked by the forecast engine, and each of the hours covered
    # by the given time range.
    #
    # This is used by `Measurement.for_time_range_dataframe` to select the
    # measurements used by a dataframe, including blanks for measurements that
    # are not present in the given time range.
    def dataframe_for_time_range(time_range)
      timestamps_table = Arel::Table.new :timestamps

      crossd_table = time_range_as_recordset(time_range)

      forecastable.select(
        arel_table[:id].as("\"station_id\""),
        timestamps_table[:timestamp].as("\"measured_at\"")
      ).joins(
        "CROSS JOIN (#{crossd_table.to_sql}) \"timestamps\""
      ).order(
        arel_table[:id].asc,
        timestamps_table[:timestamp].asc
      )
    end

    # Orders the current scope by the distance between the given coordinates and
    # the station's coordinates:
    def nearest_from(latitude, longitude)
      given_point = point latitude, longitude

      # Order the scope by the distance between 'lonlat' column and the given
      # coordinates:
      order distance(arel_table[:lonlat], given_point)
    end

    # ARel/ActiveRecord extension methods: =====================================
    # TODO: Extract the Postgres-related and PostGIS-related methods to:
    # - Postgres-ARel/ActiveRecord library to support advanced functions such as
    #   'unnest'...
    # - PostGIS-ARel/ActiveRecord library to support PostGIS functions such as
    #   'distance', 'geography_from_text', etc...

    # Postgres-related methods: ================================================
    def unnest(any_array)
      Arel::Nodes::NamedFunction.new("unnest", [any_array])
    end

    # PostGIS-related methods: =================================================
    def point(latitude, longitude)
      # Raise an argument exception if 'y' is not numeric:
      raise ArgumentException unless latitude.respond_to?(:round) &&
                                     longitude.respond_to?(:round)
      # NOTE: GIS expects points params to be "longitude" and then "latitude",
      # contrary to the somewhat popular knowledge of coordinates ordering of
      # "latitude" and then "longitude"... keep this in mind so you don't get
      # confused and think this is a mistake:
      geography_factory.point longitude, latitude
    end

    protected

      def time_range_as_recordset(time_range)
        # We'll generate the SQL for the array of timestamp values for the given
        # time_range:
        # TODO: Make this more elegant...
        min_datetime = time_range.min.to_datetime
        max_datetime = time_range.max.to_datetime

        timestamp_array = Arel::Nodes::SqlLiteral.new(
          "'{\"" +
          min_datetime.step(max_datetime, (1.to_f/24)).map { |dt| dt.utc.to_s(:db) }.join("\", \"") +
          "\"}'::TIMESTAMP[]"
        )
        Arel::SelectManager.new(self).project(unnest(timestamp_array).as("\"timestamp\""))
      end

      # PostGIS-related methods: =================================================
      def distance(column, given_point)
        # Use the spatial reference system 4396:
        geography_text = "SRID=#{given_point.srid};#{given_point.as_text}"
        Arel::Nodes::NamedFunction.new "ST_Distance",
                                       [column, geography_from_text(geography_text)]
      end

      def geography_from_text(given_text)
        Arel::Nodes::NamedFunction.new "ST_GeogFromText",
                                       [Arel::Nodes::Quoted.new(given_text)]
      end

      # The factory used to generate geographic data (points, polygon, etc)
      def geography_factory
        # NOTE: We're using an instance variable within a class method - we don't
        # want to deal with thread syncing or any of that which would happen with
        # class variables...
        @geography_factory ||= RGeo::Geographic.spherical_factory srid: 4326
      end
  end
end
