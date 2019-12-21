class BrigadeProjectsEmailBuilder
  def initialize
    @projects_created = []
    @projects_changed = []
    @projects_destroyed = []
  end

  def capture_events(&block)
    Wisper.subscribe(self, &block)
  end

  def send_email
    BrigadeProjectsMailer.daily_projects_synced(
      @projects_created,
      @projects_destroyed,
      @projects_changed
    ).deliver_now
  end

  def changes?
    @projects_created.any? ||
      @projects_changed.any? ||
      @projects_destroyed.any?
  end

  def brigade_project_created(attributes)
    @projects_created << attributes
  end

  def brigade_project_changed(attributes, changes)
    @projects_changed << [attributes, changes]
  end

  def brigade_project_destroyed(attributes)
    @projects_destroyed << attributes
  end
end
