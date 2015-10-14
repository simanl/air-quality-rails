class CreateForecasts < ActiveRecord::Migration
  def change
    create_table :forecasts do |t|
      t.references :station,
        null: false,
        index: { name: "IX_forecast_station" },
        foreign_key: true

      # The datetime range for which the forecast applies:
      t.datetime :forecast_starts_at, null: false
      t.datetime :forecast_ends_at,   null: false

      # All forecasted parameters will be stored here:
      t.jsonb :data, null: false, default: {}

      # Created At & Updated At timestamps:
      t.timestamps null: false
    end

    # This index should help us to query efficiently when obtaining a station's
    # current forecasts:
    add_index :forecasts, [:station_id, :forecast_starts_at],
      name: "UK_station_forecast_start",
      unique: true
  end
end
