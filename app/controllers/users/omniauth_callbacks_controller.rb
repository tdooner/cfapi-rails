module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def github
      user = current_user || User.find_or_create_from_omniauth(request.env['omniauth.auth'])
      user.associate_oauth_identity(request.env['omniauth.auth'])
      set_flash_message(:notice, :success, kind: 'Github') if is_navigational_format?

      if current_user
        redirect_to edit_user_registration_path
      else
        sign_in_and_redirect(user, event: :authentication)
      end
    end

    def salesforce
      user = current_user || User.find_or_create_from_omniauth(request.env['omniauth.auth'])
      user.associate_oauth_identity(request.env['omniauth.auth'])
      set_flash_message(:notice, :success, kind: 'Salesforce') if is_navigational_format?

      if current_user
        redirect_to edit_user_registration_path
      else
        sign_in_and_redirect(user, event: :authentication)
      end
    end

    def meetup
      user = current_user || User.find_or_create_from_omniauth(request.env['omniauth.auth'])
      user.associate_oauth_identity(request.env['omniauth.auth'])
      set_flash_message(:notice, :success, kind: 'Meetup') if is_navigational_format?

      if current_user
        redirect_to edit_user_registration_path
      else
        sign_in_and_redirect(user, event: :authentication)
      end
    end
  end
end
