Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  authenticate :user, ->(u) { u.is_a?(Worker) } do
    resources :workers, only: %i[show edit update]

    resources :settings, only: %i[index]

    namespace :settings do
      resources :templates, except: %i[show]
    end

    resources :clients, only: %i[index new create show edit update destroy] do
      resources :acts, only: %i[new create]
      get 'download/:signed_id', to: 'acts#download', as: :download
      post 'upload_acceptance_files', on: :member
      delete 'delete_acceptance_file/:file_id', to: 'clients#delete_acceptance_file', as: :delete_acceptance_file
    end


    root "home#index"
  end
end
