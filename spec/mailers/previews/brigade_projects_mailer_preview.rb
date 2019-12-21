class BrigadeProjectsMailerPreview < ActionMailer::Preview
  def daily_projects_synced
    BrigadeProject.transaction do
      brigade = Brigade.create(name: 'Code for Anytown')
      created_project = brigade.brigade_projects.create(name: 'Createbot')
      destroyed_project = brigade.brigade_projects.create(name: 'Destroybot').tap(&:destroy)
      changed_project = brigade.brigade_projects.create(name: 'Changedbot').tap { |p| p.update_attributes(link_url: 'foo') }

      BrigadeProjectsMailer.daily_projects_synced(
        [created_project.attributes],
        [destroyed_project.attributes],
        [[changed_project.attributes, changed_project.previous_changes]]
      )
    end
  end
end
