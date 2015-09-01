class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.references :station, index: true, foreign_key: true

      t.datetime   :measured_at,                                         null: false
      t.decimal    :temperature,                 precision: 4, scale: 2
      t.decimal    :relative_humidity,           precision: 3, scale: 2
      t.integer    :wind_direction,    limit: 2
      t.decimal    :wind_speed,                  precision: 5, scale: 2
      t.integer    :imeca_points,      limit: 2
      t.decimal    :rainfall,                    precision: 4, scale: 2

      t.jsonb      :pollutants,        default: {}

      t.timestamps                                                       null: false
    end

    # This index will help us to query efficiently to obtain a station's last measurement:
    add_index :measurements, [:station_id, :measured_at], unique: true
  end
end
