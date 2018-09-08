class Brigade < ApplicationRecord
  self.inheritance_column = nil

  include SyncGithubActivity

  scope :with_tags, ->(*tags) { where('tags ?& array[:tags]', tags: tags) }
  scope :official_cfa, -> { with_tags('Code for America', 'Official') }

  def self.from_brigade_information(object)
    find_or_initialize_by(name: object[:name]).tap do |record|
      record.assign_attributes(object)
    end
  end
end
