require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#associate_oauth_identity' do
    subject(:method) { user.associate_oauth_identity(auth_payload) }

    let(:auth_payload) do
      {
        'provider' => 'github',
        'info' => {
          'email' => 'test@example.com',
        },
        'credentials' => {
          'token' => 'abc123',
        },
        'extra' => {
          'all_emails' => [
            { 'email' => 'test@example.com', 'verified' => true },
          ],
        },
      }
    end
    let(:user) { described_class.create(email: 'foo@example.com', password: 'barbaz') }

    it 'creates an OAuth identity' do
      expect { method }.to change(user.oauth_identities, :count).from(0).to(1)
    end

    it 'still works when previously called' do
      user.associate_oauth_identity(auth_payload)
      expect { method }.not_to raise_error
    end
  end

  describe '.find_or_create_from_omniauth' do
    describe 'given a Github auth' do
      subject(:method) { described_class.find_or_create_from_omniauth(auth_payload) }

      let(:auth_payload) do
        {
          'provider' => 'github',
          'info' => {
            'email' => 'test@example.com',
          },
          'credentials' => {
            'token' => 'abc123',
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
