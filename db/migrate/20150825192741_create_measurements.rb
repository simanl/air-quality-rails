class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.references :station, index: true, foreign_key: true

      t.datetime   :measured_at,                                         null: false

      # All weather measurement attributes will be recorded here:
      t.jsonb      :weather,           default: {}

      # All pollutant measurement attributes will be recorded here:
      t.jsonb      :pollutants,        default: {}

      t.integer    :imeca_points,      limit: 2

      t.timestamps                                                       null: false
    end

    # This index will help us to query efficiently to obtain a station's last measurement:
    add_index :measurements, [:station_id, :measured_at], unique: true
  end
end
