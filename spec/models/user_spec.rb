require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#associate_oauth_identity' do
    subject(:method) { user.associate_oauth_identity(auth_payload) }

    let(:auth_payload) { oauth_auth_payload('github') }
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

      let(:auth_payload) { oauth_auth_payload('github') }

      it 'creates a new user' do
        expect { method }.to change(User, :count).by(1)
        created_user = User.last
        expect(created_user.email).to eq('user@example.com')
      end

      context 'when already associated to a different account' do
        let(:other_user) { User.create(email: 'other@example.com', password: SecureRandom.hex) }

        before do
          other_user.associate_oauth_identity(auth_payload)
        end

        it 'does not create a new user' do
          expect { method }.not_to change(User, :count)
          expect(method).to eq(other_user)
        end
      end
    end
  end
end
