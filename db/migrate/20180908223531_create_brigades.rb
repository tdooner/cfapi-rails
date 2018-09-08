class CreateBrigades < ActiveRecord::Migration[5.2]
  def change
    create_table :brigades do |t|
      t.string :name
      t.string :website
      t.string :events_url
      t.string :rss
      t.string :projects_list_url
      t.string :city
      t.decimal :latitude
      t.decimal :longitude
      t.string :type
      t.json :tags

      t.timestamps
    end
  end
end
