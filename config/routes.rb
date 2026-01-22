Rails.application.routes.draw do
  resource :session, only: :destroy

  resource :github_session, controller: :github_sessions
  get "/auth/:provider", to: redirect { |params|
    client_id = ENV.fetch("GITHUB_CLIENT_ID")
    redirect_uri = CGI.escape("http://localhost:3000/github_session")
    "https://github.com/login/oauth/authorize?client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=read:user"
  }, as: :auth_provider

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
    resources :talks, only: [ :edit, :update, :destroy ]
  end
end
