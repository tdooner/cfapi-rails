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
    def self.from_omniauth(auth_payload)
      config = Devise.omniauth_configs[:salesforce].strategy

      client = OAuth2::Client.new(
        config['client_id'],
        config['client_secret'],
        config['client_options'].deep_symbolize_keys
      )

      # "By default, the Connected Apps have an access token with an expiry of
      # 15 minutes"
      # https://dzone.com/articles/how-to-build-a-basic-salesforce-rest-api-integrati-1
      auth_payload['credentials'].delete('expires')
      auth_payload['credentials']['expires_at'] = (auth_payload['extra']['issued_at'].to_i / 1000) + (15 * 60)

      new(token_hash: OAuth2::AccessToken.new(
        client,
        auth_payload['credentials'].delete('token'),
        auth_payload['credentials']
      ).to_hash)
    end

    def refresh_if_necessary
      config = Devise.omniauth_configs[:salesforce].strategy
      token = to_token
      return unless token.expired?

      response = token.refresh!

      client = OAuth2::Client.new(
        config['client_id'],
        config['client_secret'],
        config['client_options'].deep_symbolize_keys
      )

      update_attributes(token_hash: OAuth2::AccessToken.new(
        client,
        response.token,
        refresh_token: response.refresh_token,
        expires_at: response.params['issued_at'].to_i / 1000 + (15 * 60),
        instance_url: response.params['instance_url']
      ).to_hash)
    end

    def to_token
      config = Devise.omniauth_configs[:salesforce].strategy
      client = OAuth2::Client.new(
        config['client_id'],
        config['client_secret'],
        config['client_options'].deep_symbolize_keys.merge(
          site: token_hash['instance_url']
        )
      )
      OAuth2::AccessToken.from_hash(client, token_hash)
    end
  end

  class Meetup < OAuthIdentity
    scope :admin, -> { where("token_hash::jsonb->'is_pro_admin' = ?", 'true') }

    def self.client
      config = Devise.omniauth_configs[:meetup].strategy

      OAuth2::Client.new(
        config['client_id'],
        config['client_secret'],
        config['client_options'].deep_symbolize_keys
      )
    end

    def self.from_omniauth(auth_payload)
      token_options = auth_payload['credentials'].dup
      token_options.delete('expires')
      token_options['is_pro_admin'] = auth_payload['extra']['raw_info']['is_pro_admin']
      new(
        token_hash: OAuth2::AccessToken.new(client, auth_payload['credentials']['token'], token_options).to_hash
      )
    end

    def to_token
      OAuth2::AccessToken.from_hash(self.class.client, token_hash)
    end
  end
end
