require 'rails_helper'

RSpec.describe OAuthIdentity do # rubocop:disable RSpec/FilePath
  describe 'OAuthIdentity::Salesforce.from_omniauth' do
    subject(:identity) { OAuthIdentity::Salesforce.from_omniauth(auth_payload) }

    let(:auth_payload) { oauth_auth_payload('salesforce') }

    it 'returns a properly configured OAuthIdentity' do
      expect(identity.token_hash).to include('access_token' => 'token123')
      expect(identity.token_hash).to include('refresh_token' => 'refresh123')
      expect(identity.token_hash).to include('expires_at' => 1576282432)
      expect(identity.token_hash).not_to include('expires' => false)
      expect(identity.service_user_id).to eq(auth_payload['uid'])
      expect(identity.service_username).to eq('user@example.com')
    end
  end

  describe 'OAuthIdentity::Github.from_omniauth' do
    subject(:identity) { OAuthIdentity::Github.from_omniauth(auth_payload) }

    let(:auth_payload) { oauth_auth_payload('github') }

    it 'returns a properly configured OAuthIdentity' do
      expect(identity.token_hash).to include('access_token' => 'token123')
      expect(identity.service_user_id).to eq('123456')
      expect(identity.service_username).to eq('exampleuser')
    end
  end

  describe 'OAuthIdentity::Meetup.from_omniauth' do
    subject(:identity) { OAuthIdentity::Meetup.from_omniauth(auth_payload) }

    let(:auth_payload) { oauth_auth_payload('meetup') }

    it 'returns a properly configured OAuthIdentity' do
      expect(identity.token_hash).to include('access_token' => 'token123')
      expect(identity.token_hash).to include('refresh_token' => 'refresh123')
      expect(identity.service_user_id).to eq('123456789')
      expect(identity.service_username).to eq('user@example.com')
    end
  end
end
