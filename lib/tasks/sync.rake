namespace :sync do
  desc 'sync all brigades'
  task brigade_information: :environment do
    brigade_info = BrigadeInformationClient.new

    ApiObject::BrigadeInformation.transaction do
      existing_objects = brigade_info.each.map do |brigade_info_hash|
        ApiObject::BrigadeInformation
          .find_or_initialize_by(object_id: brigade_info_hash['name'])
          .tap { |r| r.update_attributes(body: brigade_info_hash) }
      end

      ApiObject::BrigadeInformation.where.not(id: existing_objects).destroy_all

      Brigade.replace_all_from_brigade_information(
        ApiObject::BrigadeInformation.all
      )
    end
  end
end
