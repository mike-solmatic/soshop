ActsAsTenant.configure do |config|
  # Tenant is set explicitly per request in controllers; background jobs
  # must set it themselves. Unscoped access is reserved for the admin area.
  config.require_tenant = false
end
