class StationSerializer < ActiveModel::Serializer
  attributes :id, :code, :name, :short_name, :latlon

  def latlon
    "#{object.latitude},#{object.longitude}"
  end
end
