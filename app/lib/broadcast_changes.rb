# If you include this module on an ActiveRecord model, it will emit events with
# specific attribute structure beyond what typical ActiveRecord callbacks
# feature.
#
# Usage:
#
# class BrigadeLeader < ApplicationRecord
#   include BroadcastChanges
# end
#
# The events will be emitted based on the class name:
# * brigade_leader_created
# * brigade_leader_destroyed
# * brigade_leader_changed
module BroadcastChanges
  extend ActiveSupport::Concern

  included do
    include Wisper::Publisher

    after_commit :broadcast_updates
  end

  def broadcast_updates
    prefix = self.class.name.underscore

    if id_previously_changed?
      broadcast(prefix + '_created', attributes)
    elsif destroyed?
      broadcast(prefix + '_destroyed', attributes)
    elsif previous_changes.any?
      broadcast(prefix + '_changed', attributes, previous_changes)
    end
  end
end
