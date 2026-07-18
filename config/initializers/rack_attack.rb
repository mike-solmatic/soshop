# Request throttling & brute-force protection.
class Rack::Attack
  # Allow local development traffic through unthrottled.
  safelist("allow-localhost") do |req|
    Rails.env.development? && [ "127.0.0.1", "::1" ].include?(req.ip)
  end

  # Global request rate limit per IP.
  throttle("req/ip", limit: 300, period: 5.minutes, &:ip)

  # Brute-force protection: login endpoints, per IP.
  throttle("logins/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.post? && req.path.match?(%r{\A/(sellers|admins)/sign_in})
  end

  # Brute-force protection: login attempts per account email.
  throttle("logins/email", limit: 8, period: 1.minute) do |req|
    if req.post? && req.path.match?(%r{\A/(sellers|admins)/sign_in})
      email = req.params.dig("seller", "email") || req.params.dig("admin", "email")
      email.to_s.downcase.presence
    end
  end

  # Throttle password reset requests.
  throttle("password_resets/ip", limit: 5, period: 15.minutes) do |req|
    req.ip if req.post? && req.path.match?(%r{\A/(sellers|admins)/password})
  end

  self.throttled_responder = lambda do |_request|
    [ 429, { "Content-Type" => "application/json" }, [ { error: "Rate limit exceeded. Try again later." }.to_json ] ]
  end
end
