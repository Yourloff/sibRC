Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  authenticate :user, ->(u) { u.is_a?(Worker) } do
    resources :workers, only: %i[show]
    resources :settings, only: %i[index]

    namespace :settings do
      resources :templates
    end

    resources :clients, only: %i[index new create show edit update destroy]

    root "home#index"
  end
end
