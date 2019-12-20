class CreateMetricSnapshots < ActiveRecord::Migration[5.2]
  def change
    create_table :metric_snapshots do |t|
      t.string :metric_name
      t.numeric :metric_value
      t.timestamp :created_at

      t.references :related_object,
        polymorphic: true,
        index: { name: :idx_metric_snapshots_related_object }
      t.index [:metric_name, :created_at]
    end
  end
end
