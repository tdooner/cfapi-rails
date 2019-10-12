require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.find_or_create_from_omniauth' do
    describe 'given a Github auth' do
      subject(:method) { described_class.find_or_create_from_omniauth(auth_payload) }

      let(:auth_payload) do
        {
          'provider' => 'github',
          'info' => {
            'email' => 'test@example.com',
          },
          'extra' => {
            'all_emails' => [
              { 'email' => 'test@example.com', 'verified' => true },
            ],
          },
        }
      end

      it 'creates a new user' do
        expect { method }.to change(User, :count).by(1)
        created_user = User.last
        expect(created_user.email).to eq('test@example.com')
      end
    end
  end
end
