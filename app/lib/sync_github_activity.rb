module SyncGithubActivity
  extend ActiveSupport::Concern

  def sync_github_activity!
    raise 'No projects_list_url' unless projects_list_url.present?

    # TODO:
    puts 'syncing'
  end
end
