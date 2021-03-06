class BrigadeProject < ApplicationRecord
  include BroadcastChanges
  include MetricSnapshottable

  metric :github_stargazers_count, -> { github&.body&.dig("stargazers_count") }
  metric :github_watchers_count, -> { github&.body&.dig("subscribers_count") }
  metric :github_open_issues_count, -> { github&.body&.dig("open_issues_count") }
  metric :github_network_count, -> { github&.body&.dig("network_count") }
  metric :github_size, -> { github&.body&.dig("size") }

  belongs_to :brigade
  has_one :github_repo, primary_key: :code_url, foreign_key: :object_id,
    class_name: 'ApiObject::GithubRepo'
  has_one :github_repo_details, primary_key: :code_url, foreign_key: :object_id,
    class_name: 'ApiObject::GithubRepoDetails'

  def self.replace_all_from_project_database(api_objects)
    BrigadeProject.transaction do
      brigade_projects = api_objects.flat_map do |api_object|
        organization = api_object.body['organization']
        projects = api_object.body['projects']
        next unless organization && projects

        brigade = Brigade.find_by(name: organization['name'])
        next unless brigade

        projects.map do |project|
          inferred_project_name = URI(project['code_url']).path.split('/').last if project['code_url'] rescue nil
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

  def github
    @github ||= ApiObject::GithubRepo.find_by(object_id: code_url)
  end
end
