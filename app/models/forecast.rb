class Forecast < ActiveRecord::Base
  belongs_to :station
  validates :station, presence: true

  has_and_belongs_to_many :measurements

  validates :starts_at, :ends_at, presence: true

  store_accessor :data,
    :ozone_index,
    :ozone_category,
    # Both Toracic (PM > 10nm) and Respirable (PM > 2.5 nm) are Inhalable Particles:
    :toracic_particles_index,
    :toracic_particles_category,   # PM10
    :respirable_particles_index,
    :respirable_particles_category # PM2.5

  validate :at_least_one_parameter_is_forecasted

  scope :current, -> { where arel_table[:starts_at].gteq(DateTime.now) }
  scope :grouped_by_station, -> { group :station_id }
  scope :last_forecasted_24_hours, -> { last_forecasted_interval hours: 24 }

  class << self
    # Returns the forecast engine's time range for which the given datetime
    # belongs to:
    def engine_dataframe_time_range_for(given_datetimeish)
      beginning_of_day = given_datetimeish.at_beginning_of_day

      [
        beginning_of_day..beginning_of_day.advance(hours: 5),
        beginning_of_day.advance(hours: 6)..beginning_of_day.advance(hours: 11),
        beginning_of_day.advance(hours: 12)..beginning_of_day.advance(hours: 17),
        beginning_of_day.advance(hours: 18)..beginning_of_day.advance(hours: 23)
      ].detect { |x| x.cover? given_datetimeish }
    end

    def for_time_range(given_time_range, right_unbounded = false)
      range_conditions = arel_table[:starts_at].lteq(given_time_range.min)

      range_conditions = range_conditions.and(
        arel_table[:ends_at].gteq(given_time_range.max)
      ) unless right_unbounded

      where range_conditions
    end

    # Returns the forecasts created/updated from measurements in the given time
    # range:
    def updated_from_time_range(given_time_range)
      where last_dataframe_ended_at: given_time_range
    end

    def last_forecasted_interval(given_interval = { hours: 24 })
      # Get the subquery aliased as 'base_dataframe':
      last_forecasts = last_forecasted_interval_subquery(given_interval)
        .as("\"last_forecasts\"")

      # Create the join conditions between the measurements table and the subquery:
      join_condition = arel_table[:station_id]
        .eq(last_forecasts[:station_id])
        .and(arel_table[:starts_at].gteq(last_forecasts[:starts_at]))

      joins arel_table.create_join(
        last_forecasts,
        last_forecasts.create_on(join_condition),
        Arel::Nodes::InnerJoin
      )
    end

    private

      def last_forecasted_interval_subquery(given_interval = { hours: 24 })
        given_interval = given_interval.map { |k,v| "#{v} #{k.to_s.pluralize}" }.join ", "
        interval = Arel::Nodes::SqlLiteral.new("INTERVAL '#{given_interval}'")
        ceiling = Arel::Nodes::Max.new [arel_table[:ends_at]]
        floor = Arel::Nodes::Subtraction.new(ceiling, interval)

        grouped_by_station.select arel_table[:station_id],
                                  floor.as("\"starts_at\"")
      end
  end

  protected

    def at_least_one_parameter_is_forecasted
      errors.add(
        :data, 'at least one parameter should be forecasted'
      ) if data.blank? || data.values.uniq == [nil]
    end
end
