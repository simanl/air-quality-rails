# Subscribe to Measurement events:

Rails.application.config.to_prepare do
  begin
    ActiveSupport::Notifications.subscribe(
      'measurement.create',
      MeasurementEventSubscriber.new
    )
  rescue => e
    byebug
  end
end
