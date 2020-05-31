class AddSentToMixpanelAtToMetricSnapshot < ActiveRecord::Migration[5.2]
  def change
    change_table :metric_snapshots do |t|
      t.timestamp :sent_to_mixpanel_at
    end
  end
end
