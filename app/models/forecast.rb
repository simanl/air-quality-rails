class Forecast < ActiveRecord::Base
  belongs_to :station
  validates :station, presence: true

  validates :forecasted_datetime, presence: true

  store_accessor :data,
    :ozone,
    # Both Toracic (PM > 10nm) and Respirable (PM > 2.5 nm) are Inhalable Particles:
    :toracic_particles,   # PM10
    :respirable_particles # PM2.5

  validate :at_least_one_parameter_is_forecasted

  protected

    def at_least_one_parameter_is_forecasted
      errors.add(
        :data, 'at least one parameter should be forecasted'
      ) if data.blank? || data.values.uniq == [nil]
    end

end
