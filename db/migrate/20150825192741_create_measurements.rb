class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.references :station, null: false, index: true, foreign_key: true

      # The measurement datetime:
      t.datetime :measured_at, null: false

      # The measured weather parameters will be stored here:
      t.jsonb :weather, null: false, default: {}

      # The measured pollution parameters will be stored here:
      t.jsonb :pollutants, null: false, default: {}

      # The resulting IMECA points:
      t.integer :imeca_points, limit: 2

      # The measurement Created At & Updated At timestamps:
      t.timestamps null: false
    end

    # This index should help us to query efficiently when obtaining a station's
    # last measurement:
    add_index :measurements, [:station_id, :measured_at], unique: true
  end
end
