class CreateBrigadeLeaders < ActiveRecord::Migration[5.2]
  def change
    create_table :brigade_leaders do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.references :brigade

      t.timestamps
    end
  end
end
