require 'rails_helper'

RSpec.describe BrigadeProject do
  describe '.replace_all_from_project_database' do
    subject { described_class.replace_all_from_project_database(api_objects) }

    let(:brigade) { Brigade.create(name: 'Code for Tulsa') }

    context 'with a new BrigadeProject' do
      let(:api_objects) do
        [
          ApiObject::BrigadeProjectIndexEntry.new(
            body: {
              'organization' => {
                'name' => brigade.name,
              },
              'projects' => [
                {
                  'name' => 'Courtbot',
                  'link_url' => 'http://example.com/courtbot',
                  'code_url' => 'http://example.com/courtbot-code',
                },
              ],
            }
          ),
        ]
      end

      it 'creates a new BrigadeProject' do
        expect { subject }.to change(described_class, :count).by(1)

        created = described_class.last
        expect(created.name).to eq('Courtbot')
        expect(created.link_url).to eq('http://example.com/courtbot')
        expect(created.code_url).to eq('http://example.com/courtbot-code')
      end
    end

    context 'with an old BrigadeProject' do
      let!(:old_brigade_project) { brigade.brigade_projects.create(name: 'Courtbot') }
      let(:api_objects) { [] }

      it 'removes the old BrigadeProject' do
        expect(old_brigade_project).to be_persisted
        subject
        expect { old_brigade_project.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
