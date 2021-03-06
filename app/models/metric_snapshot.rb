require 'mixpanel-ruby'

class MetricSnapshot < ApplicationRecord
  belongs_to :related_object, polymorphic: true
  scope :unsent_to_mixpanel, -> { where(sent_to_mixpanel_at: nil) }

  FAKE_MIXPANEL_USER_ID = 'metric_snapshot_user'.hash

  def send_to_mixpanel
    return unless ENV['MIXPANEL_TOKEN'].present?
    return if sent_to_mixpanel_at.present?

    mixpanel = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])

    related_object_fields =
      if related_object.present?
        related_object.attributes.transform_keys { |k| "#{related_object_type.underscore}_#{k}" }
      else
        {}
      end

    event_fields = {
      value: metric_value,
      time: created_at.to_i,
    }.merge(related_object_fields)

    success = nil
    if created_at <= 5.days.ago
      if ENV['MIXPANEL_API_KEY'].present?
        success = mixpanel.import(ENV['MIXPANEL_API_KEY'], FAKE_MIXPANEL_USER_ID, metric_name, event_fields)
      else
        Rails.logger.warn "Cannot send MetricSnapshot to Mixpanel: Older than 5 days and MIXPANEL_API_KEY missing."
      end
    else
      success = mixpanel.track(FAKE_MIXPANEL_USER_ID, metric_name, event_fields)
    end

    if success
      touch(:sent_to_mixpanel_at)
    else
      Rails.logger.info "Failed to send event to Mixpanel."
    end
  end
end
