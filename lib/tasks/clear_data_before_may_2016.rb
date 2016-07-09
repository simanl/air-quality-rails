# How to call:
# require "tasks/clear_data_before_may_2016" ; Tasks::ClearDataBeforeMay2016.new.up
module Tasks
  class ClearDataBeforeMay2016 < ActiveRecord::Migration
    class Station < ActiveRecord::Base
      has_many :measurements
      belongs_to :last_measurement, class_name: "Measurement"
    end

    class BackupMeasurement < ActiveRecord::Base
    end

    class Measurement < ActiveRecord::Base
    end

    def up
      create_backup_table!
      backup_preservable_data!
      disable_references!
      clear_discarded_data!
      restore_preserved_data!
      enable_references!
      clear_backup!
    end

    private

      def clear_backup!
        drop_table :backup_measurements
      end

      def preserved_columns(given_table)
        %w(station_id measured_at weather pollutants imeca_points created_at updated_at)
          .map { |column_name| given_table[column_name.to_sym] }
      end

      def select_data_to_backup
        Measurement.select(*preserved_columns(measurements_table))
                   .where(measurements_table[:measured_at].gteq(partition_point))
                   .order(measurements_table[:measured_at].asc, measurements_table[:station_id].asc)
      end

      def select_data_to_restore
        BackupMeasurement.select(*preserved_columns(backup_measurements_table))
                         .order(backup_measurements_table[:id].asc)
      end

      def backup_preservable_data!
        # Execute the "INSERT SELECT" statement:
        ActiveRecord::Base.connection.execute backup_insert_manager.to_sql
      end

      def restore_preserved_data!
        # Execute the "INSERT SELECT" statement:
        ActiveRecord::Base.connection.execute restore_insert_manager.to_sql

        Station.all.each do |station|
          station.update(
            last_measurement: station.measurements.order(measured_at: :desc).first
          )
        end
      end

      def create_backup_table!
        create_table :backup_measurements do |t|
          t.references :station,      null: false, index: false, foreign_key: false
          t.datetime   :measured_at,  null: false
          t.jsonb      :weather,      null: false, default: {}
          t.jsonb      :pollutants,   null: false, default: {}
          t.integer    :imeca_points, limit: 2
          t.timestamps                null: false
        end
      end

      def backup_insert_manager
        insert_manager = migration_insert_manager measurements_table,
                                                  backup_measurements_table

        insert_manager.select select_data_to_backup.arel
        insert_manager
      end

      def restore_insert_manager
        insert_manager = migration_insert_manager backup_measurements_table,
                                                  measurements_table

        insert_manager.select select_data_to_restore.arel
        insert_manager
      end

      def migration_insert_manager(from_table, to_table)
        # The Insert Manager, which will generate the "INSERT SELECT" statement:
        insert_manager = Arel::InsertManager.new ActiveRecord::Base
        insert_manager.into to_table
        insert_manager.columns.concat preserved_columns(to_table)
        insert_manager
      end

      def partition_point
        @partition_point ||= DateTime.rfc3339("2016-05-01T00:00:00-06:00")
      end

      def disable_references!
        remove_foreign_key :stations, column: :last_measurement_id
      rescue ArgumentError
      end

      def enable_references!
        add_foreign_key :stations, :measurements, column: :last_measurement_id
      end

      def clear_discarded_data!
        ActiveRecord::Base.connection.execute truncate_forecasts_sql
        ActiveRecord::Base.connection.execute truncate_measurements_sql
        ActiveRecord::Base.connection.execute clear_station_last_measurements_sql
        ActiveRecord::Base.connection.execute truncate_measurement_forecasts_sql
        ActiveRecord::Base.connection.execute truncate_active_station_forecasts_sql
      end

      def clear_station_last_measurements_sql
        "UPDATE \"stations\" SET \"last_measurement_id\" = NULL"
      end

      def truncate_measurement_forecasts_sql
        "TRUNCATE TABLE \"forecasts_measurements\" RESTART IDENTITY"
      end

      def truncate_active_station_forecasts_sql
        "TRUNCATE TABLE \"active_station_forecasts\" RESTART IDENTITY"
      end

      def truncate_forecasts_sql
        "TRUNCATE TABLE \"forecasts\" RESTART IDENTITY CASCADE"
      end

      def truncate_measurements_sql
        "TRUNCATE TABLE \"measurements\" RESTART IDENTITY CASCADE"
      end

      def backup_measurements_table
        @_backup_measurements_table ||= BackupMeasurement.arel_table
      end

      def measurements_table
        @_measurements_table ||= Measurement.arel_table
      end
  end
end
