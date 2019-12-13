class AddHasSalesforceAccountToUser < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.boolean :has_salesforce_account
    end
  end
end
