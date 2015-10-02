class ForecastSerializer < ActiveModel::Serializer
  attributes :id, :forecasted_datetime
  attributes :ozone, :toracic_particles, :respirable_particles
  attributes :updated_at
end
