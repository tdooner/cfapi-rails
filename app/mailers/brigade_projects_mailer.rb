class BrigadeProjectsMailer < ApplicationMailer
  def daily_projects_synced(created, destroyed, changed)
    @created_projects = created
    @destroyed_projects = destroyed
    @changed_projects = changed

    mail(
      to: 'tdooner@codeforamerica.org',
      cc: 'calfano@codeforamerica.org,anlawyer@berkeley.edu',
      subject: "Brigade Project Update - #{Date.today}"
    )
  end
end
