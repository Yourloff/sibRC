Rails.application.routes.draw do
  get "acts/new"
  get "acts/create"
  devise_for :users, controllers: { registrations: "users/registrations" }

  authenticate :user, ->(u) { u.is_a?(Worker) } do
    resources :workers, only: %i[show edit update]
    resources :settings, only: %i[index]

    namespace :settings do
      resources :templates
    end

    resources :clients, only: %i[index new create show edit update destroy] do
      resources :acts, only: %i[new create]
    end

    root "home#index"
  end
end
