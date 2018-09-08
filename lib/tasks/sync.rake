namespace :sync do
  desc 'sync all brigades'
  task brigade_information: :environment do
    brigade_info = BrigadeInformationClient.new

    Brigade.transaction do
      brigade_info.each do |brigade_info_hash|
        Brigade
          .from_brigade_information(brigade_info_hash)
          .save
      end
    end
  end
end
