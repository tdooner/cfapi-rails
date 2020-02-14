module MetricSnapshottable
  extend ActiveSupport::Concern

  def calculate_metrics
    self.class.metrics.map do |name, blk|
      [name, instance_exec(&blk)]
    end
  end

  included do
    cattr_accessor :metrics, default: []

    has_many :metric_snapshots, as: :related_object
  end

  class_methods do
    def metric(name, blk)
      metrics << [name, blk]
    end
  end
end
