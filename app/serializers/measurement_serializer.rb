class MeasurementSerializer < ActiveModel::Serializer
  attributes :id, :measured_at, :measured_at_rfc822, :temperature, :relative_humidity,
    :wind_direction, :wind_speed, :imeca_points, :imeca_category, :precipitation

  attributes :carbon_monoxide, :nitric_oxide, :nitrogen_dioxide,
    :nitrogen_oxides, :ozone, :sulfur_dioxide,
    :toracic_particles, :respirable_particles

  def measured_at_rfc822
    object.measured_at.rfc822
  end

end
