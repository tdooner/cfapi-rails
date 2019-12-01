module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def github
      if current_user
        current_user.associate_oauth_identity(request.env['omniauth.auth'])
        redirect_to edit_user_registration_path
      else
        user = User.find_or_create_from_omniauth(request.env['omniauth.auth'])

        sign_in_and_redirect(user, event: :authentication)
        set_flash_message(:notice, :success, kind: 'Github') if is_navigational_format?
      end
    end

    def salesforce
      if current_user
        current_user.associate_oauth_identity(request.env['omniauth.auth'])
        redirect_to edit_user_registration_path
      else
        user = User.find_or_create_from_omniauth(request.env['omniauth.auth'])

        sign_in_and_redirect(user, event: :authentication)
        set_flash_message(:notice, :success, kind: 'Salesforce') if is_navigational_format?
      end
    end

    def meetup
      if current_user
        current_user.associate_oauth_identity(request.env['omniauth.auth'])
        redirect_to edit_user_registration_path
      else
        user = User.find_or_create_from_omniauth(request.env['omniauth.auth'])
        user.associate_ouath_identity(request.env['omniauth.auth'])
        sign_in_and_redirect(user, event: :authentication)
      end

      set_flash_message(:notice, :success, kind: 'Meetup') if is_navigational_format?
    end
  end
end
