class Measurement < ActiveRecord::Base
  belongs_to :station

  store_accessor :pollutants,
    :carbon_monoxide,
    :nitric_oxide,
    :nitrogen_dioxide,
    :nitrogen_oxide, # https://en.wikipedia.org/wiki/Nitrogen_oxide
    :ozone,
    :sulfur_dioxide,
    :suspended_particulate_matter,   # SPM
    :respirable_suspended_particles, # PM10
    :fine_particles,                 # PM2.5
    :tout

  validates :measured_at,
    presence: true,
    uniqueness: { scope: :station, message: "already exists for station" }

  validates :wind_direction,
    numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 360 },
    allow_nil: true

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

end
