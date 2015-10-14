class CreateForecastsMeasurements < ActiveRecord::Migration
  def change
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
  end
end
