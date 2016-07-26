class MigrateStationsLastMeasurementToMeasurementsMostRecent < ActiveRecord::Migration
  def up
    add_column :measurements,
               :most_recent,
               :boolean,
               null: false,
               default: false

    add_index :measurements,
              [:station_id, :most_recent],
              unique: true,
              where: "most_recent",
              name: "UK_station_most_recent_measurement"

    execute measurements_update_join_sql

    remove_column :stations, :last_measurement_id
  end

  def down
    add_column :stations, :last_measurement_id, :integer
    add_index :stations, [:last_measurement_id], name: :UK_station_last_measurement, unique: true
    add_foreign_key :stations, :measurements, column: :last_measurement_id, on_delete: :nullify
    execute stations_recreate_last_measurement_sql
    remove_column :measurements, :most_recent
  end

  private

    def stations_recreate_last_measurement_sql
      projection = most_recent_measurements
        .project(measurements[:id], measurements[:station_id])
        .as "\"most_recent_measurements\""

      join_conditions = stations[:id].eq(projection[:station_id])

      "UPDATE \"stations\" SET " \
      "\"last_measurement_id\" = \"most_recent_measurements\".\"id\" " \
      "FROM #{projection.to_sql} WHERE #{join_conditions.to_sql}"
    end

    def measurements
      @measurements ||= Arel::Table.new :measurements
    end

    def stations
      @stations ||= Arel::Table.new :stations
    end

    def most_recent_measurements
      measurements.where measurements[:most_recent].eq(true)
    end

    def measurements_grouped_by_station
      measurements.group measurements[:station_id]
    end

    def latest_of_each_station
      last_measured_at = Arel::Nodes::Max.new [measurements[:measured_at]]
      measurements_grouped_by_station
        .project measurements[:station_id],
                 last_measured_at.as("\"measured_at\"")
    end

    def measurements_update_join_sql
      "UPDATE \"measurements\" SET \"most_recent\" = 't' " \
      "FROM (#{latest_of_each_station.to_sql}) \"latest_of_each_station\" " \
      "WHERE \"measurements\".\"station_id\" = \"latest_of_each_station\".\"station_id\"" \
      "AND  \"measurements\".\"measured_at\" = \"latest_of_each_station\".\"measured_at\""
    end
end
