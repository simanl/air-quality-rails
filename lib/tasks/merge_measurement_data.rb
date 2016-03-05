module Tasks
  class MergeMeasurementData < ActiveRecord::Migration
    def up
      remove_index :measurements, name: "IX_measurement_station"
      rename_index :measurements, "UK_station_measured_at", "UK_last_measurements_measured_at"
      rename_table :measurements, :measurements_last

      create_table :measurements do |t|
        t.references :station, null: false, index: { name: "IX_measurement_station" }, foreign_key: true
        t.datetime :measured_at, null: false
        t.jsonb :weather, null: false, default: {}
        t.jsonb :pollutants, null: false, default: {}
        t.integer :imeca_points, limit: 2
        t.timestamps null: false
      end
      add_index :measurements, [:station_id, :measured_at], name: "UK_station_measured_at", unique: true

      unions = <<-EOF
(#{tables_to_merge.map{ |t| select_from_table_query t }.join(') UNION (')})
EOF
      insert_select = "SELECT * FROM (#{unions}) AS msrmnts ORDER BY #{order}"
      execute "INSERT INTO measurements (#{columns}) (#{insert_select})"

      tables_to_merge.map { |t| drop_table t, force: :cascade }
      
      add_foreign_key :forecasts_measurements, :measurements
    end

    private
      def tables_to_merge
        [:measurements_2014, :measurements_last]
      end

      def columns
        "station_id, measured_at, weather, pollutants, imeca_points, created_at, updated_at"
      end

      def order
        "measured_at ASC, station_id ASC"
      end

      def select_from_table_query(table_name)
        <<-EOF
SELECT #{columns}
FROM #{table_name}
ORDER BY #{order}
        EOF
      end
  end
end
