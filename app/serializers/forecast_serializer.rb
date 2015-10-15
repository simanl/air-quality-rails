class ForecastSerializer < ActiveModel::Serializer
  attributes :id, :starts_at, :ends_at
  attributes :ozone, :toracic_particles, :respirable_particles
  attributes :updated_at
end
