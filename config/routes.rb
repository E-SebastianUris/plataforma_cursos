Rails.application.routes.draw do
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  namespace :admin do
    root "categories#index"
    resources :categories
    resources :courses
    resources :lessons
    resources :users, except: :show
    resources :reviews, only: %i[index destroy]
  end

  namespace :api do
    namespace :v1 do
      post "login", to: "sessions#create"
      resources :courses, only: %i[index show] do
      resources :reviews, only: %i[index create]
      end
      resources :orders, controller: "enrollments", only: %i[index create]
      get "profile", to: "users#profile"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "sessions#new"
end
