Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    post "auth/signup", to: "auth#signup"
    post "auth/login", to: "auth#login"
    get "auth/me", to: "auth#me"

    get "dashboard/summary", to: "dashboard#summary"
    get "team", to: "team#index"
    post "team", to: "team#create"
    get "activity_logs", to: "activity_logs#index"
    get "workspace", to: "workspaces#show"
    patch "workspace", to: "workspaces#update"

    get "leads/export", to: "leads#export"
    post "leads/import", to: "leads#import"
    resources :leads do
      resources :notes, only: [:create]
    end
  end
end
