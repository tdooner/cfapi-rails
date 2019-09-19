class UpdateBrigadeToOnlyHaveSomeFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :brigades, :website
    remove_column :brigades, :events_url
    remove_column :brigades, :rss
    remove_column :brigades, :projects_list_url
    remove_column :brigades, :city
    remove_column :brigades, :latitude
    remove_column :brigades, :longitude
    remove_column :brigades, :type
    remove_column :brigades, :tags
    remove_column :brigades, :social_profiles

    add_column :brigades, :github_url, :string
    add_column :brigades, :meetup_url, :string
  end
end
