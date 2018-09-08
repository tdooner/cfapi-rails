class UpdateBrigadeJsonToJsonB < ActiveRecord::Migration[5.2]
  def change
    change_column :brigades, :social_profiles, :jsonb
    change_column :brigades, :tags, :jsonb
  end
end
