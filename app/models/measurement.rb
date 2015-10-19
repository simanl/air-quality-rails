class Measurement < ActiveRecord::Base

  include Concerns::PersistenceNotifications

  belongs_to :station
  validates :station, presence: true

  has_and_belongs_to_many :forecasts

  store_accessor :weather,
    :atmospheric_pressure,
    :precipitation,
    :relative_humidity,
    :solar_radiation,
    :temperature,
    :wind_direction,
    :wind_speed

  store_accessor :pollutants,
    :carbon_monoxide,
    :nitric_oxide,
    :nitrogen_dioxide,
    :nitrogen_oxides, # https://en.wikipedia.org/wiki/Nitrogen_oxide
    :ozone,
    :sulfur_dioxide,
    :suspended_particulate_matter,   # SPM
    # Both Toracic (PM > 10nm) and Respirable (PM > 2.5 nm) are Inhalable Particles:
    :toracic_particles,   # PM10
    :respirable_particles # PM2.5

  validates :measured_at,
    presence: true,
    uniqueness: { scope: :station, message: "already exists for station" }

  validates :wind_direction,
    numericality: { greater_than_or_equal_to: 0, less_than: 360 },
    allow_nil: true

  after_create :update_station_last_measurement!

  def self.since(timestampish)
    timestamp = if timestampish.respond_to? :split
      # It's a string
      DateTime.parse timestampish
    else
      timestampish
    end

    where(self.arel_table[:measured_at].gteq timestamp)
  end

  def self.latest
    order(measured_at: :desc)
  end

  def wind_cardinal_direction
    case wind_direction
    when 339..360 then 'north'
    when 1..23 then 'north'
    when 24..68 then 'northeast'
    when 69..113 then 'east'
    when 114..158 then 'southeast'
    when 159..203 then 'south'
    when 204..248 then 'southwest'
    when 249..293 then 'west'
    when 294..338 then 'northwest'
    end if wind_direction.present?
  end

  def imeca_category
    case imeca_points
    when 0..50 then 'good'
    when 50..100 then 'regular'
    when 101..150 then 'bad'
    when 151..200 then 'very_bad'
    else 'extremely_bad'
    end if imeca_points.present?
  end

  protected

    def update_station_last_measurement!
      station.update last_measurement_id: station.measurements.latest
        .limit(1).pluck(:id).first
    end

end
