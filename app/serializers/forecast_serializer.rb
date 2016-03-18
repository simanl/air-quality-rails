class ForecastSerializer < ActiveModel::Serializer
  attributes :id, :starts_at, :starts_at_rfc822, :ends_at, :ends_at_rfc822

  attributes :ozone_category,
             :toracic_particles_category,
             :respirable_particles_category

  attributes :updated_at

  def starts_at_rfc822
    object.starts_at.rfc822
  end

  def ends_at_rfc822
    object.ends_at.rfc822
  end
end
