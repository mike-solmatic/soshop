# Content Security Policy — scripts restricted to self; images allow the
# Facebook CDN + avatar hosts used for customer profile pictures.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data, "https://fonts.gstatic.com"
    policy.img_src     :self, :data, :https
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self, :unsafe_inline, "https://fonts.googleapis.com"
    policy.frame_ancestors :none
    policy.base_uri    :self
    policy.form_action :self, "https://www.facebook.com"
  end
end
