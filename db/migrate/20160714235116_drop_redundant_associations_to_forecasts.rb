class DropRedundantAssociationsToForecasts < ActiveRecord::Migration
  def up
    drop_table :active_station_forecasts
    drop_table :forecasts_measurements
  end

  def down
    create_table :forecasts_measurements do |t|
      t.references :forecast,
        null: false,
        index: { name: "FK_measurement_forecast" },
        foreign_key: true

      t.references :measurement,
        null: false,
        index: { name: "FK_forecast_measurement" },
        foreign_key: true
    end

    add_index :forecasts_measurements, [:forecast_id, :measurement_id],
      unique: true,
      name: "UK_forecast_measurement"

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
