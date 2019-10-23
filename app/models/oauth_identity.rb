class OAuthIdentity < ApplicationRecord
  belongs_to :user

  class Github < OAuthIdentity
    def self.client
      config = Devise.omniauth_configs[:github].strategy

      OAuth2::Client.new(
        config['client_id'],
        config['client_secret'],
        config['client_options'].deep_symbolize_keys
      )
    end

    def self.from_omniauth(auth_payload)
      # assume the user_id is defined by the calling method
      new(
        token_hash: OAuth2::AccessToken.new(client, auth_payload['credentials']['token']).to_hash
      )
    end

    def to_token
      OAuth2::AccessToken.from_hash(self.class.client, token_hash)
    end
  end

  class Salesforce < OAuthIdentity
    def self.client
      config = Devise.omniauth_configs[:salesforce].strategy

      OAuth2::Client.new(
        config['client_id'],
        config['client_secret'],
        config['client_options'].deep_symbolize_keys
      )
    end

    def self.from_omniauth(auth_payload)
      # assume the user_id is defined by the calling method
      new(token_hash: OAuth2::AccessToken.new(
        client,
        auth_payload['credentials'].delete('token'),
        auth_payload['credentials']
      ).to_hash)
    end

    def to_token
      OAuth2::AccessToken.from_hash(self.class.client, token_hash)
    end
  end

  class Meetup < OAuthIdentity
    def self.client
      config = Devise.omniauth_configs[:meetup].strategy

      OAuth2::Client.new(
        config['client_id'],
        config['client_secret'],
        config['client_options'].deep_symbolize_keys
      )
    end

    def self.from_omniauth(auth_payload)
      # assume the user_id is defined by the calling method
      new(
        token_hash: OAuth2::AccessToken.new(client, auth_payload['credentials']['token']).to_hash
      )
    end

    def to_token
      OAuth2::AccessToken.from_hash(self.class.client, token_hash)
    end
  end

end
