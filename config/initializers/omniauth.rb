OmniAuth.config.allowed_request_methods = [ :get, :post ]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,
    Rails.application.credentials.github.client_id,
    Rails.application.credentials.github.client_secret,
    scope: "read:user"
end
