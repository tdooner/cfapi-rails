require 'rails_helper'

RSpec.describe BrigadeProject do
  describe '.replace_all_from_project_database' do
    subject { described_class.replace_all_from_project_database(api_objects) }

    let(:brigade) { Brigade.create(name: 'Code for Tulsa') }
    let(:valid_api_object) do
      ApiObject::BrigadeProjectIndexEntry.new(
        body: {
          'organization' => {
            'name' => brigade.name,
          },
          'projects' => [
            {
              'name' => 'Courtbot',
              'link_url' => 'http://example.com/courtbot',
              'code_url' => 'http://example.com/org/courtbot',
            },
          ],
        }
      )
    end

    context 'with a new project ApiObject' do
      let(:api_objects) { [valid_api_object] }

      it 'creates a new BrigadeProject' do
        expect { subject }.to change(described_class, :count).by(1)

        created = described_class.last
        expect(created.name).to eq('Courtbot')
        expect(created.link_url).to eq('http://example.com/courtbot')
        expect(created.code_url).to eq('http://example.com/org/courtbot')
      end

      it 'broadcasts a "brigade_project_created" event' do
        expect { subject }.to broadcast(:brigade_project_created)
      end
    end

    context 'with a new project ApiObject with no project "name"' do
      let(:api_objects) { [api_object_with_no_project_name] }
      let(:api_object_with_no_project_name) do
        valid_api_object.dup.tap do |api_object|
          api_object.body['projects'][0].delete('name')
        end
      end

      it 'infers the name from the end of the code_url' do
        expect { subject }.to change(described_class, :count).by(1)

        created = described_class.last
        expect(created.name).to eq('courtbot')
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

      it 'broadcasts a "brigade_project_destroyed" event' do
        expect { subject }.to broadcast(:brigade_project_destroyed)
      end
    end

    context 'with a changed project ApiObject' do
      let(:original_api_object) { valid_api_object.dup }
      let(:changed_api_object) do
        valid_api_object.dup.tap do |api_object|
          api_object.body['projects'][0]['code_url'] =
            'http://example.com/some-other-code-url'
        end
      end
      let(:api_objects) { [changed_api_object] }

      before do
        described_class.replace_all_from_project_database([original_api_object])
      end

      it 'updates the old BrigadeProject' do
        expect { subject }
          .to change { described_class.last.code_url }
          .from('http://example.com/org/courtbot')
          .to('http://example.com/some-other-code-url')
      end

      it 'broadcasts a "brigade_project_changed" event' do
        expect { subject }.to broadcast(:brigade_project_changed)
      end
    end
  end
end
