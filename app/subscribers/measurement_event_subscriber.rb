class MeasurementEventSubscriber

  # Gets called whenever a nContent SDK event happens, such as lifecycle events,
  # persistence events, etc:
  def call(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    case event.name
    when 'measurement.create'
      UpdateForecastsJob.perform_later
    end
  end

end
