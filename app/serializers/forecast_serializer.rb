class ForecastSerializer < ActiveModel::Serializer
  attributes :id, :forecast_starts_at, :forecast_ends_at
  attributes :ozone, :toracic_particles, :respirable_particles
  attributes :updated_at
end
