class Brigade < ApplicationRecord
  has_many :brigade_leaders
  has_many :brigade_projects
  has_many :metric_snapshots, as: :related_object

  cattr_accessor :metrics

  def self.metric(name, blk)
    Brigade.metrics ||= []
    Brigade.metrics << [name, blk]
  end

  def calculate_metrics
    Brigade.metrics.map { |name, blk| [name, instance_exec(&blk)] }
  end

  metric :meetup_past_rsvps, -> { meetup&.body&.fetch('past_rsvps', nil) }
  metric :meetup_repeat_rsvpers, -> { meetup&.body&.fetch('repeat_rsvpers', nil) }
  metric :meetup_past_events, -> { meetup&.body&.fetch('past_events', nil) }
  metric :meetup_member_count, -> { meetup&.body&.fetch('member_count', nil) }
  metric :meetup_upcoming_events, -> { meetup&.body&.fetch('upcoming_events', nil) }
  metric :meetup_organizer_count, -> { meetup&.body&.fetch('organizers', [])&.count }

  def self.replace_all_from_brigade_information(brigades)
    Brigade.transaction do
      official_brigades = brigades.map do |brigade|
        json = brigade.body
        is_official = json['tags'].include?('Code for America') && json['tags'].include?('Official')

        existing = Brigade.find_by(name: json['name'])
        new_attributes = {
          name: json['name'],
          meetup_url: (json['events_url'] if json['events_url'].try(:match, %r{\Ahttps?://www\.meetup\.com})),
          github_url: (json['projects_list_url'] if json['projects_list_url'].try(:match, %r{\Ahttps?://github\.com})),
        }.compact

        if !existing && is_official
          Brigade.create(new_attributes)
        elsif existing && !is_official
          # remove no-longer-official brigades
          existing.destroy
          nil
        elsif existing
          # propagate some useful attributes onto the Brigade model itself
          existing.meetup_url ||= new_attributes[:meetup_url]
          existing.github_url ||= new_attributes[:github_url]
          existing.save
          existing
        end
      end

      Brigade.where.not(id: official_brigades).destroy_all
    end
  end

  def to_param
    name
  end

  def meetup_urlname
    return unless meetup_url

    URI(meetup_url)
      .path
      .gsub(/^\/|\/$/, '') # "/Code-for-Foo/" => "Code-for-Foo"
  end

  def meetup
    return unless meetup_urlname

    @meetup ||= ApiObject::MeetupGroup.with_meetup_urlname(meetup_urlname).first
  end
end
