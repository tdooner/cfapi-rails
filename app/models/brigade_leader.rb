class BrigadeLeader < ApplicationRecord
  belongs_to :brigade

  def self.replace_all_from_salesforce(api_objects)
    BrigadeLeader.transaction do
      brigade_leaders = api_objects.map do |api_object|
        salesforce_brigade = api_object.body['npe5__Organization__r']
        salesforce_contact = api_object.body['npe5__Contact__r']
        brigade = Brigade.find_by(name: salesforce_brigade['Name'])
        next unless brigade

        brigade
          .brigade_leaders
          .find_or_initialize_by(email: salesforce_contact['Email'])
          .tap { |leader| leader.update_attributes(name: salesforce_contact['Name']) }
      end

      BrigadeLeader.where.not(id: brigade_leaders).destroy_all
    end
  end
end
