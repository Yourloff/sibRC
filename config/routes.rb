Rails.application.routes.draw do
  root 'home#index'

  namespace :settings do
    get 'templates', to: 'templates#index', as: 'templates'
  end
end
