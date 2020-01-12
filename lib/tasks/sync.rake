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

  desc 'sync meetup events'
  task meetup_group_events: :environment do
    client = MeetupGroupInfoClient.new(OAuthIdentity::Meetup.admin.last.to_token)

    ApiObject::MeetupGroup.transaction do
      existing_objects = ApiObject::MeetupGroup.all.map do |group|
        ApiObject::MeetupGroupEvents
          .find_or_create_by(object_id: group.object_id)
          .tap { |r| r.update_attributes(body: client.group_events(group.body['urlname']).to_a) }
          .tap(&:touch)
      end

      ApiObject::MeetupGroupEvents.where.not(id: existing_objects).destroy_all
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

    email_builder = BrigadeProjectsEmailBuilder.new
    email_builder.capture_events do
      BrigadeProject.replace_all_from_project_database(
        ApiObject::BrigadeProjectIndexEntry.all
      )
    end
    email_builder.capture_events do
      Rake::Task['sync:project_github'].invoke
    end
    email_builder.send_email if email_builder.changes?
  end

  desc 'sync brigade project githubs'
  task project_github: :environment do
    github_identity = OAuthIdentity::Github.last.to_token
    client = Octokit::Client.new(access_token: github_identity.token)

    ApiObject::GithubRepo.transaction do
      projects = BrigadeProject.where('code_url LIKE ?', '%github.com%')

      existing_objects = projects.each_with_index.map do |project, i|
        ApiObject::GithubRepo.find_or_create_by(object_id: project.code_url).tap do |existing|
          conditional_headers = {}
          if existing.body.present?
            conditional_headers['If-Modified-Since'] = Time.parse(existing.body['updated_at']).rfc2822
          end

          Rails.logger.info "Loading project details for #{project.code_url} (#{i}/#{projects.length})..."
          begin
            repo = client.repo(URI(project.code_url).path[1..-1], headers: conditional_headers)
          rescue => ex
            Rails.logger.error "  Error Fetching: #{ex.message}"
            next
          end

          response = client.last_response
          Rails.logger.info "  Got status: #{response.status}"
          Rails.logger.info "  Rate limit: #{response.headers['X-Ratelimit-Remaining']} Remaining"

          existing.touch

          next if response.status.to_i == 304
          existing.update_attributes(body: repo.to_h)
          project.update_attributes(
            last_modified_at: response.headers[:last_modified],
            last_pushed_at: repo.pushed_at
          )
        end
      end.compact

      ApiObject::GithubRepo.where.not(id: existing_objects).destroy_all
    end
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
