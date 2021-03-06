class StationSerializer < ActiveModel::Serializer
  attributes :id, :code, :name, :short_name, :latlon

  def latlon
    "#{object.latitude},#{object.longitude}"
  end

  has_one  :last_measurement,  serializer: MeasurementSerializer
  has_many :current_forecasts, serializer: ForecastSerializer
end
