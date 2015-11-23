class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.string :code, index: { unique: true, name: "UK_station_code" }
      t.string :name
      t.string :short_name
      t.st_point :lonlat, geographic: true
      t.references :last_measurement, index: { unique: true, name: "UK_station_last_measurement" }
      t.boolean :is_forecastable, null: false, default: false, index: { name: 'IX_forecastable_station' }
      t.timestamps null: false
    end
  end
end
