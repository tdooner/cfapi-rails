namespace :metrics do
  task capture_brigades: :environment do
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

  task capture_projects: :environment do
    metric_date = Date.today.beginning_of_day

    BrigadeProject.find_each do |project|
      metrics = project.calculate_metrics

      MetricSnapshot.transaction do
        metrics.each do |metric_name, metric_value|
          MetricSnapshot
            .where(
              related_object: project,
              created_at: metric_date,
              metric_name: metric_name
            )
            .first_or_initialize
            .update_attributes(metric_value: metric_value)
        end
      end
    end
  end

  desc 'capture all the metrics'
  task capture_all: %i[capture_brigades capture_projects]
end
