OmniAuth.config.allowed_request_methods = [ :get, :post ]

# Configure full host for callback URL generation
OmniAuth.config.full_host = "https://trug.pl" if Rails.env.production?

# Only configure OmniAuth when credentials are available
# This handles cases where credentials cannot be decrypted (no RAILS_MASTER_KEY)
begin
  if Rails.application.credentials.github
    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :github,
        Rails.application.credentials.github.client_id,
        Rails.application.credentials.github.client_secret,
        scope: "read:user"
    end
  end
rescue ActiveSupport::MessageEncryptor::InvalidMessage
  # Credentials not available (e.g., during asset precompilation without master key)
end
