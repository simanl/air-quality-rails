class SetStationsLastMeasurementForeignKeyNullify < ActiveRecord::Migration
  def up
    remove_foreign_key :stations, column: :last_measurement_id
    add_foreign_key :stations,
                    :measurements,
                    column: :last_measurement_id,
                    on_delete: :nullify
  end

  def down
    remove_foreign_key :stations, column: :last_measurement_id
    add_foreign_key :stations, :measurements, column: :last_measurement_id
  end
end
