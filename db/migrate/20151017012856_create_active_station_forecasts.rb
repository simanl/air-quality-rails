class CreateActiveStationForecasts < ActiveRecord::Migration
  def change
    create_table :active_station_forecasts do |t|
      t.references :station,
        null: false,
        index: { name: "FK_active_forecast_station" },
        foreign_key: true

      t.references :forecast,
        null: false,
        index: { name: "FK_active_station_forecast" },
        foreign_key: true
    end

    add_index :active_station_forecasts, [:station_id, :forecast_id],
      unique: true,
      name: "UK_active_station_forecast"
  end
end
