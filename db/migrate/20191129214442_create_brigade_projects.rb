class CreateBrigadeProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :brigade_projects do |t|
      t.string :name
      t.string :code_url
      t.string :link_url

      t.references :brigade
    end
  end
end
