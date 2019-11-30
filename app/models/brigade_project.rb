class BrigadeProject < ApplicationRecord
  belongs_to :brigade

  def self.replace_all_from_project_database(api_objects)
    BrigadeProject.transaction do
      brigade_projects = api_objects.flat_map do |api_object|
        organization = api_object.body['organization']
        projects = api_object.body['projects']
        next unless organization && projects

        brigade = Brigade.find_by(name: organization['name'])
        next unless brigade

        projects.map do |project|
          brigade
            .brigade_projects
            .find_or_initialize_by(name: project['name'])
            .tap { |p| p.update_attributes(link_url: project['link_url'], code_url: project['code_url']) }
        end
      end

      BrigadeProject.where.not(id: brigade_projects).destroy_all
    end
  end
end
