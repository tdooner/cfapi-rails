Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions',
  }

  resources :brigade, only: %i[show edit] do
    post :add_leader, on: :member
  end

  root to: 'home#show'
end
