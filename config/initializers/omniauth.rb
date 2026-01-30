OmniAuth.config.allowed_request_methods = [ :get, :post ]

github_creds = if Rails.env.production?
  {
    client_id: ENV.fetch("GITHUB_CLIENT_ID"),
    client_secret: ENV.fetch("GITHUB_CLIENT_SECRET")
  }
else
  {
    client_id: Rails.application.credentials.github.client_id,
    client_secret: Rails.application.credentials.github.client_secret
  }
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,
    github_creds[:client_id],
    github_creds[:client_secret],
    scope: "read:user"
end
