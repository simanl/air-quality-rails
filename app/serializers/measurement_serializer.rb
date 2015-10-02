class MeasurementSerializer < ActiveModel::Serializer
  attributes :id, :measured_at, :temperature, :relative_humidity,
    :wind_direction, :wind_speed, :imeca_points, :precipitation

  attributes :carbon_monoxide, :nitric_oxide, :nitrogen_dioxide,
    :nitrogen_oxides, :ozone, :sulfur_dioxide, :suspended_particulate_matter,
    :toracic_particles, :respirable_particles

end
