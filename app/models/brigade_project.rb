class BrigadeProject < ApplicationRecord
  include Wisper::Publisher

  belongs_to :brigade

  after_commit :publish_updates

  def publish_updates
    if id_previously_changed?
      broadcast(:brigade_project_created, attributes)
    elsif destroyed?
      broadcast(:brigade_project_destroyed, attributes)
    elsif previous_changes.any?
      broadcast(:brigade_project_changed, attributes, previous_changes)
    end
  end

  def self.replace_all_from_project_database(api_objects)
    BrigadeProject.transaction do
      brigade_projects = api_objects.flat_map do |api_object|
        organization = api_object.body['organization']
        projects = api_object.body['projects']
        next unless organization && projects

        brigade = Brigade.find_by(name: organization['name'])
        next unless brigade

        projects.map do |project|
          inferred_project_name = URI(project['code_url']).path.split('/').last
          project_name = project['name'] || inferred_project_name

          brigade
            .brigade_projects
            .find_or_initialize_by(name: project_name)
            .tap { |p| p.update_attributes(link_url: project['link_url'], code_url: project['code_url']) }
        end
      end

      BrigadeProject.where.not(id: brigade_projects).destroy_all
    end
  end
end
