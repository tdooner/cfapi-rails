class ApiObject
  class MeetupGroup < ApiObject
    scope :with_meetup_urlname, ->(urlname) { where("LOWER(body::jsonb->>'urlname') = LOWER(?)", urlname) }
  end
end
