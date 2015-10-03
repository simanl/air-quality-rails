class AddLastMeasurementForeignKeyToStations < ActiveRecord::Migration
  def change
    add_foreign_key :stations, :measurements, column: :last_measurement_id
  end
end
