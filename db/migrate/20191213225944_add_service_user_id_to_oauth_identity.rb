class AddServiceUserIdToOAuthIdentity < ActiveRecord::Migration[5.2]
  def change
    OAuthIdentity.destroy_all

    change_table :oauth_identities do |t|
      t.string :service_user_id, null: false
      t.string :service_username, null: false
    end
  end
end
