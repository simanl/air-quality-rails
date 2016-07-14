class AddForecastLastDataframeEndedAt < ActiveRecord::Migration
  class Forecast < ActiveRecord::Base
  end

  def up
    # Create the column where we'll store the last input dataframe's measurement
    # timestamp that was used to generate the last batch of forecasts:
    add_column :forecasts,
               :last_dataframe_ended_at,
               :datetime,
               index: { name: "IX_forecast_last_dataframe_ended_at" }

    # Set all the existing rows' last_dataframe_ended_at column to the
    # presumed last measurement timestamp used overall...
    max_starts_at = Forecast.maximum(:starts_at)
    Forecast.update_all last_dataframe_ended_at: max_starts_at.advance(hours: -1) \
      if max_starts_at.present?

    # Now, no row can have last_dataframe_ended_at set to NULL:
    change_column_null :forecasts, :last_dataframe_ended_at, false
  end

  def down
    remove_column :forecasts, :last_dataframe_ended_at
  end
end
