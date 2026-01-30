OmniAuth.config.allowed_request_methods = [ :get, :post ]

# Only configure OmniAuth when credentials are available (skip during asset precompilation)
if Rails.application.credentials.github
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :github,
      Rails.application.credentials.github.client_id,
      Rails.application.credentials.github.client_secret,
      scope: "read:user"
  end
end
