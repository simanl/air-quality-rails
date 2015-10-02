class CreateForecasts < ActiveRecord::Migration
  def change
    create_table :forecasts do |t|
      t.references :station, null: false, index: true, foreign_key: true

      # The datetime in which the forecast applies for:
      t.datetime :forecasted_datetime, null: false

      # All forecasted parameters will be stored here:
      t.jsonb :data, null: false, default: {}

      # Created At & Updated At timestamps:
      t.timestamps null: false
    end

    # This index should help us to query efficiently when obtaining a station's
    # current forecasts:
    add_index :forecasts, [:station_id, :forecasted_datetime], unique: true
  end
end
