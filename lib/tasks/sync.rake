namespace :sync do
  desc 'sync all brigades'
  task brigade_information: :environment do
    brigade_info = BrigadeInformationClient.new

    ApiObject::BrigadeInformation.transaction do
      existing_objects = brigade_info.each.map do |brigade_info_hash|
        ApiObject::BrigadeInformation
          .find_or_initialize_by(object_id: brigade_info_hash['name'])
          .tap { |r| r.update_attributes(body: brigade_info_hash) }
          .tap(&:touch)
      end

      ApiObject::BrigadeInformation.where.not(id: existing_objects).destroy_all

      Brigade.replace_all_from_brigade_information(
        ApiObject::BrigadeInformation.all
      )
    end
  end

  desc 'sync brigade leaderships'
  task brigade_leaders: :environment do
    identity = OAuthIdentity::Salesforce.last
    identity.refresh_if_necessary

    client = SalesforceBrigadeLeadersClient.new(identity.to_token)

    ApiObject::SalesforceBrigadeLeader.transaction do
      existing_objects = client.map do |result|
        ApiObject::SalesforceBrigadeLeader
          .find_or_create_by(object_id: result['Id'])
          .tap { |r| r.update_attributes(body: result) }
          .tap(&:touch)
      end

      ApiObject::SalesforceBrigadeLeader.where.not(id: existing_objects).destroy_all

      BrigadeLeader.replace_all_from_salesforce(
        ApiObject::SalesforceBrigadeLeader.all
      )
    end
  end

  desc 'sync meetup groups'
  task meetup_groups: :environment do
    client = MeetupGroupInfoClient.new(OAuthIdentity::Meetup.admin.last.to_token)

    ApiObject::MeetupGroup.transaction do
      existing_objects = client.groups.map do |group|
        ApiObject::MeetupGroup
          .find_or_create_by(object_id: group['id'])
          .tap { |r| r.update_attributes(body: group) }
          .tap(&:touch)
      end

      ApiObject::MeetupGroup.where.not(id: existing_objects).destroy_all
    end
  end

  desc 'sync meetup members'
  task meetup_group_members: :environment do
    client = MeetupGroupInfoClient.new(OAuthIdentity::Meetup.admin.last.to_token)

    ApiObject::MeetupGroup.transaction do
      existing_objects = ApiObject::MeetupGroup.all.map do |group|
        ApiObject::MeetupGroupMembers
          .find_or_create_by(object_id: group.object_id)
          .tap { |r| r.update_attributes(body: client.group_members(group.object_id).to_a) }
          .tap(&:touch)
      end

      ApiObject::MeetupGroupMembers.where.not(id: existing_objects).destroy_all
    end
  end

  desc 'sync brigade projects'
  task projects: :environment do
    client = BrigadeProjectIndexClient.new

    ApiObject::BrigadeProjectIndexEntry.transaction do
      existing_objects = client.projects_by_organization.map do |organization, projects|
        ApiObject::BrigadeProjectIndexEntry
          .find_or_create_by(object_id: organization['name'])
          .tap { |o| o.update_attributes(body: { organization: organization, projects: projects }) }
          .tap(&:touch)
      end

      ApiObject::BrigadeProjectIndexEntry.where.not(id: existing_objects).destroy_all
    end

    BrigadeProject.replace_all_from_project_database(
      ApiObject::BrigadeProjectIndexEntry.all
    )
  end

  desc 'sync salesforce accounts'
  task salesforce_accounts: :environment do
    identity = OAuthIdentity::Salesforce.last
    identity.refresh_if_necessary
    client = SalesforceAdminUsersClient.new(identity.to_token)

    User.transaction do
      User.update_all(has_salesforce_account: false)

      client.each do |record|
        User.where(email: record['Email']).update_all(has_salesforce_account: true)
      end
    end
  end
end
