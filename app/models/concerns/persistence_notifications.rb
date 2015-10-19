module Concerns

  module PersistenceNotifications

    extend ActiveSupport::Concern

    included do
      after_create do |record|
        record.send :emit_notification, 'create'
      end

      after_update do |record|
        record.send :emit_notification, 'update'
      end
    end

    private

      def emit_notification(event_name)
        event_class = self.class.name.underscore
        ActiveSupport::Notifications.instrument("#{event_class}.#{event_name}") do |notification_payload|
          notification_payload.merge!(id: id)
        end
      end

  end

end
