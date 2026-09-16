Rails.application.routes.draw do
  root "admin/courses#index"

  namespace :admin do
    resources :categories
    resources :courses
  end

  namespace :api do
    namespace :v1 do
      # Futuros endpoints para la API
    end
  end
end