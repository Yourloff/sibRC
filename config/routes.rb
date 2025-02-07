Rails.application.routes.draw do
  devise_for :users
  root 'home#index'

  namespace :settings do
    resources :templates
  end
end
