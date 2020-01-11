class AddLastUpdatedToBrigadeProjects < ActiveRecord::Migration[5.2]
  def change
    change_table :brigade_projects do |t|
      t.datetime :last_modified_at
      t.datetime :last_pushed_at
    end
  end
end
