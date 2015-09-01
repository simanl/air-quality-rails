class MeasurementSerializer < ActiveModel::Serializer
  attributes :id, :measured_at, :temperature, :relative_humidity, :wind_direction, :wind_speed, :imeca_points, :rainfall

  attributes :carbon_monoxide, :nitric_oxide, :nitrogen_dioxide, :nitrogen_oxide,
    :ozone, :sulfur_dioxide, :suspended_particulate_matter,
    :respirable_suspended_particles, :fine_particles

end
