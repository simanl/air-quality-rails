class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.string :code
      t.string :name
      t.string :short_name
      t.st_point :lonlat, geographic: true

      t.timestamps null: false
    end

    add_index :stations, :code, unique: true
  end
end
