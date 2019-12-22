class AddSlugToBrigade < ActiveRecord::Migration[5.2]
  def change
    add_column :brigades, :slug, :string
    add_index :brigades, :slug, unique: true
  end
end
