class CreateBrigadeProjectsSearchFields < ActiveRecord::Migration[5.2]
  def change
    create_view :brigade_projects_search_fields,
      materialized: true
  end
end
