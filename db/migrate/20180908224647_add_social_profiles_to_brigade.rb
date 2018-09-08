class AddSocialProfilesToBrigade < ActiveRecord::Migration[5.2]
  def change
    change_table :brigades do |t|
      t.json :social_profiles
    end
  end
end
