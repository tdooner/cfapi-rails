class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :confirmable, :registerable, :recoverable,
    :rememberable, :validatable, :omniauthable, :trackable,
    omniauth_providers: %i[github salesforce meetup]
  has_many :oauth_identities
  has_many :brigade_leaders, primary_key: :email, foreign_key: :email

  def associate_oauth_identity(auth_payload)
    case auth_payload['provider']
    when 'github'
      oauth_identities.where(type: 'OAuthIdentity::Github').destroy_all
      oauth_identities << OAuthIdentity::Github.from_omniauth(auth_payload)
    when 'salesforce'
      oauth_identities.where(type: 'OAuthIdentity::Salesforce').destroy_all
      oauth_identities << OAuthIdentity::Salesforce.from_omniauth(auth_payload)
    when 'meetup'
      oauth_identities.where(type: 'OAuthIdentity::Meetup').destroy_all
      oauth_identities << OAuthIdentity::Meetup.from_omniauth(auth_payload)
    end
  end

  def self.find_or_create_from_omniauth(auth_payload)
    user = case auth_payload['provider']
           when 'github'
             if (identity = OAuthIdentity::Github.find_by(service_user_id: auth_payload['uid']))
               identity.user
             else
               User.find_or_initialize_by(email: auth_payload['info']['email']).tap do |user|
                 user.confirmed_at = Time.now if auth_payload['extra']['all_emails'].find { |e| e['email'] == user.email && e['verified'] } && user.confirmed_at.nil?
               end
             end
           when 'salesforce'
             # TODO: DRY this up and test Salesforce / Meetup
             if (identity = OAuthIdentity::Salesforce.find_by(service_user_id: auth_payload['uid']))
               identity.user
             else
               User.find_or_initialize_by(email: auth_payload['extra']['email']).tap do |user|
                 user.confirmed_at = Time.now if auth_payload['extra']['email_verified'] && user.confirmed_at.nil?
               end
             end
           when 'meetup'
             # TODO: DRY this up and test Salesforce / Meetup
             if (identity = OAuthIdentity::Meetup.find_by(service_user_id: auth_payload['uid']))
               identity.user
             else
               User.find_or_initialize_by(email: auth_payload['info']['email']).tap do |user|
                 user.confirmed_at = Time.now if auth_payload['extra']['raw_info']['status'] == 'active' && user.confirmed_at.nil?
               end
             end
           end

    if user.new_record?
      user.assign_attributes(password: Devise.friendly_token)
    end

    # TODO: Handle multiple OAuth emails here.
    user.save
    user
  end

  def admin?
    has_salesforce_account
  end

  def can_manage_brigade?(brigade)
    admin? || brigade_leaders.detect { |l| l.brigade_id == brigade.id }
  end
end
