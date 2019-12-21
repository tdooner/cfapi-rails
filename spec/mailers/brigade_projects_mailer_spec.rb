require 'rails_helper'

RSpec.describe BrigadeProjectsMailer do
  describe '#daily_projects_synced' do
    let(:brigade) { Brigade.create(name: 'Code for Anytown') }
    let(:mail) do
      described_class.daily_projects_synced(
        created_projects,
        destroyed_projects,
        changed_projects
      )
    end

    # Recreate the data passed in by the BrigadeProjectsEmailBuilder
    let(:project_createbot) { brigade.brigade_projects.create(name: 'Createbot') }
    let(:project_destroybot) { brigade.brigade_projects.create(name: 'Destroybot').tap(&:destroy) }
    let(:project_changedbot) { brigade.brigade_projects.create(name: 'Changedbot').tap { |p| p.update_attributes(link_url: 'foo') } }

    let(:created_projects) { [project_createbot.attributes] }
    let(:destroyed_projects) { [project_destroybot.attributes] }
    let(:changed_projects) { [[project_changedbot.attributes, project_changedbot.previous_changes]] }

    it 'renders the body' do
      expect(mail.body.encoded).to include('Hello')
    end
  end
end
