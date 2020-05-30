class CreateBrigadeProjectsSearches < ActiveRecord::Migration[5.2]
  def change
    create_view :brigade_projects_searches, materialized: true
  end
end
