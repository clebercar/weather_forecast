Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :weather do
    resources :search, only: [:index, :create]
  end
end
