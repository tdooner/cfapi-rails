class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :confirmable, :registerable, :recoverable,
    :rememberable, :validatable, :omniauthable, :trackable,
    omniauth_providers: %i[github salesforce meetup]
  has_many :oauth_identities

  def self.find_or_create_from_omniauth(auth_payload)
    user = case auth_payload['provider']
           when 'github'
             User.find_or_initialize_by(email: auth_payload['info']['email']).tap do |user|
               user.confirmed_at = Time.now if auth_payload['extra']['all_emails'].find { |e| e['email'] == user.email && e['verified'] } && user.confirmed_at.nil?
               user.oauth_identities << OAuthIdentity::Github.from_omniauth(auth_payload)
             end
           when 'salesforce'
             User.find_or_initialize_by(email: auth_payload['extra']['email']).tap do |user|
               user.confirmed_at = Time.now if auth_payload['extra']['email_verified'] && user.confirmed_at.nil?
               user.oauth_identities << OAuthIdentity::Salesforce.from_omniauth(auth_payload)
             end
           when 'meetup'
             User.find_or_initialize_by(email: auth_payload['info']['email']).tap do |user|
               user.confirmed_at = Time.now if auth_payload['extra']['raw_info']['status'] == 'active' && user.confirmed_at.nil?
               user.oauth_identities << OAuthIdentity::Meetup.from_omniauth(auth_payload)
             end
           end

    if user.new_record?
      user.assign_attributes(password: Devise.friendly_token)
    end

    # TODO: Handle multiple OAuth emails here.
    user.save
    user
  end
end
