# Facebook Connect for customer accounts.
#
# Set FACEBOOK_APP_ID / FACEBOOK_APP_SECRET in .env (development) or your
# production credential store. The registered OAuth redirect URI must be:
#   <host>/customers/auth/facebook/callback
#
# When the credentials are absent in development, OmniAuth runs in mock mode
# so the full login flow remains demoable without a Facebook app.
FACEBOOK_OAUTH_CONFIGURED = ENV["FACEBOOK_APP_ID"].present? && ENV["FACEBOOK_APP_SECRET"].present?

Devise.setup do |config|
  config.omniauth :facebook,
                  ENV.fetch("FACEBOOK_APP_ID", "not-configured"),
                  ENV.fetch("FACEBOOK_APP_SECRET", "not-configured"),
                  # Permissions requested from the user
                  scope: "email,public_profile",
                  # Fields fetched from the Graph API for auth.info / auth.extra.raw_info
                  info_fields: "id,name,email,picture.width(200).height(200)",
                  # auth.info.image => https://graph.facebook.com/<uid>/picture?width=200&height=200
                  image_size: { width: 200, height: 200 },
                  secure_image_url: true,
                  # If the user previously declined the email permission,
                  # ask again on their next login instead of silently omitting it
                  auth_type: "rerequest"
end

if Rails.env.development? && !FACEBOOK_OAUTH_CONFIGURED
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(
    provider: "facebook",
    uid: "101582937465012",
    info: {
      name: "Alex Rivera",
      email: "alex.rivera@example.com",
      image: "https://i.pravatar.cc/200?u=alex.rivera"
    },
    credentials: { token: "mock-token", expires_at: 1.week.from_now.to_i }
  )
  Rails.logger.info "[omniauth] FACEBOOK_APP_ID not set — Facebook login is MOCKED in development"
end

# Never expose auth failure internals; route failures back through Devise.
OmniAuth.config.on_failure = proc do |env|
  Customers::OmniauthCallbacksController.action(:failure).call(env)
end
