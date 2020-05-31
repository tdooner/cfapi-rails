class UpdateBrigadeProjectsSearchesToVersion2 < ActiveRecord::Migration[5.2]
  def change
    update_view :brigade_projects_searches,
      version: 2,
      revert_to_version: 1,
      materialized: true
  end
end
