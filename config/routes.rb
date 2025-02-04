Rails.application.routes.draw do
  devise_for :users
  root 'home#index'

  namespace :settings do
    get 'templates', to: 'templates#index', as: 'templates'
  end
end
