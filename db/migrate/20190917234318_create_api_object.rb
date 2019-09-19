class CreateApiObject < ActiveRecord::Migration[5.2]
  def change
    create_table :api_objects do |t|
      t.string :type
      t.string :object_id
      t.jsonb :body

      t.timestamps
    end
  end
end
