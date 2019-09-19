# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Brigade do
  describe '.replace_all_from_brigade_information' do
    subject(:method) { described_class.replace_all_from_brigade_information(api_objects) }

    let(:api_objects) do
      [
        ApiObject::BrigadeInformation.new(
          object_id: 'Code for Somewhere',
          body: {
            'tags' => ['Code for America', 'Official'],
          }
        )
      ]
    end

    it 'creates a new brigade' do
      expect { method }.to change(described_class, :count).by(1)
    end

    describe 'when the brigade is not official' do
      before do
        api_objects[0].update(body: api_objects[0].body.merge('tags' => ['Code for America']))
      end

      it 'does not create the brigade' do
        expect { method }.not_to change(described_class, :count)
      end
    end
  end
end
