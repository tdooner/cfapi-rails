class AddServiceUserIdToOAuthIdentity < ActiveRecord::Migration[5.2]
  def change
    change_table :oauth_identities do |t|
      t.string :service_user_id
    end
  end
end
