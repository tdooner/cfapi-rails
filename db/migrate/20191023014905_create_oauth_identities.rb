class CreateOAuthIdentities < ActiveRecord::Migration[5.2]
  def change
    create_table :oauth_identities do |t|
      t.string :type, null: false
      t.references :user
      t.json :token_hash, null: false
      t.timestamps

      t.index %i[type user_id], unique: true
    end
  end
end
