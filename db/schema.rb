# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151014185034) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "forecasts", force: :cascade do |t|
    t.integer  "station_id",                      null: false
    t.datetime "forecast_starts_at",              null: false
    t.datetime "forecast_ends_at",                null: false
    t.jsonb    "data",               default: {}, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "forecasts", ["station_id", "forecast_starts_at"], name: "UK_station_forecast_start", unique: true, using: :btree
  add_index "forecasts", ["station_id"], name: "IX_forecast_station", using: :btree

  create_table "forecasts_measurements", force: :cascade do |t|
    t.integer "forecast_id",    null: false
    t.integer "measurement_id", null: false
  end

  add_index "forecasts_measurements", ["forecast_id", "measurement_id"], name: "UK_forecast_measurement", unique: true, using: :btree
  add_index "forecasts_measurements", ["forecast_id"], name: "FK_measurement_forecast", using: :btree
  add_index "forecasts_measurements", ["measurement_id"], name: "FK_forecast_measurement", using: :btree

  create_table "measurements", force: :cascade do |t|
    t.integer  "station_id",                          null: false
    t.datetime "measured_at",                         null: false
    t.jsonb    "weather",                default: {}, null: false
    t.jsonb    "pollutants",             default: {}, null: false
    t.integer  "imeca_points", limit: 2
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "measurements", ["station_id", "measured_at"], name: "UK_station_measured_at", unique: true, using: :btree
  add_index "measurements", ["station_id"], name: "IX_measurement_station", using: :btree

  create_table "stations", force: :cascade do |t|
    t.string    "code"
    t.string    "name"
    t.string    "short_name"
    t.geography "lonlat",              limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.integer   "last_measurement_id"
    t.integer   "status",              limit: 2,                                                default: 0, null: false
    t.datetime  "created_at",                                                                               null: false
    t.datetime  "updated_at",                                                                               null: false
  end

  add_index "stations", ["code"], name: "UK_station_code", unique: true, using: :btree
  add_index "stations", ["last_measurement_id"], name: "UK_station_last_measurement", unique: true, using: :btree
  add_index "stations", ["status"], name: "IX_station_status", using: :btree

  add_foreign_key "forecasts", "stations"
  add_foreign_key "forecasts_measurements", "forecasts"
  add_foreign_key "forecasts_measurements", "measurements"
  add_foreign_key "measurements", "stations"
  add_foreign_key "stations", "measurements", column: "last_measurement_id"
end
