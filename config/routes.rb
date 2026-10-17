Rails.application.routes.draw do
  devise_for :users
  root to: "products#index"

  resources :products, only: [:index, :show]
  resource :cart, only: [:show, :update]
  resources :cart_items, only: [:create, :update, :destroy]
  resources :orders, only: [:index, :show, :new, :create]

  namespace :admin do
    root to: "dashboards#show"
    resources :categories, except: [:show]
    resources :products
    resources :orders, only: [:index, :show, :update]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
