Rails.application.routes.draw do
  devise_for :users
  root 'home#index'

  resources :settings, only: %i[index]

  namespace :settings do
    resources :templates
  end
end
