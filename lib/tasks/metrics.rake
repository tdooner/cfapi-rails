namespace :metrics do
  desc 'capture all the metrics'
  task capture_all: :environment do
    metric_date = Date.today.beginning_of_day

    Brigade.find_each do |brigade|
      metrics = brigade.calculate_metrics

      MetricSnapshot.transaction do
        metrics.each do |metric_name, metric_value|
          MetricSnapshot
            .where(
              related_object: brigade,
              created_at: metric_date,
              metric_name: metric_name
            )
            .first_or_initialize
            .update_attributes(metric_value: metric_value)
        end
      end
    end
  end
end
