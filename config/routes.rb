Rails.application.routes.draw do
  resource :session, only: :destroy

  get "/auth/:provider", to: "github_sessions#new", as: :auth_provider
  get "/auth/github/callback", to: "github_sessions#create"
  post "/auth/github/callback", to: "github_sessions#create"
  get "/auth/failure", to: "github_sessions#failure"

  get "up" => "rails/health#show", as: :rails_health_check
  get "/video-thumbnails/:provider/:id", to: "video_thumbnails#show", as: :video_thumbnail

  resources :attendances, only: [ :new, :create ]

  root "pages#home"
  get "/archive", to: "pages#archive"
  get "/rss", to: "pages#rss", defaults: { format: :xml }, as: :rss

  namespace :admin do
    root "dashboard#index"
    resources :meetups do
      resources :talks, except: [ :index ]
    end
    resources :talks, only: [ :index, :edit, :update, :destroy ]
  end
end
