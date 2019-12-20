class MetricSnapshot < ApplicationRecord
  belongs_to :related_object, polymorphic: true
end
