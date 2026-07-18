module Customers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Facebook Connect callback. The storefront passes the seller slug through
    # the OmniAuth request phase (?seller_slug=...) so the customer record is
    # created inside the right tenant.
    def facebook
      seller = Seller.active.find_by(slug: omniauth_seller_slug)

      if seller.nil?
        redirect_to root_path, alert: "This shop is unavailable." and return
      end

      auth = request.env["omniauth.auth"]
      customer = ActsAsTenant.with_tenant(seller) { Customer.from_omniauth(auth, seller) }

      Rails.logger.info(
        "[facebook-connect] seller=#{seller.slug} uid=#{customer.uid} " \
        "name=#{customer.name.inspect} email=#{customer.email.inspect} avatar=#{customer.avatar_url.present?}"
      )

      sign_in_and_redirect customer, event: :authentication
      set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.warn "[facebook-connect] failed to persist customer: #{e.message}"
      redirect_to storefront_path(seller.slug), alert: "We could not sign you in with Facebook."
    end

    # OmniAuth failures (user cancelled the dialog, CSRF mismatch, Facebook
    # error) land here — send the user back to the storefront they came from.
    def failure
      slug = omniauth_seller_slug
      destination = slug.present? && Seller.active.exists?(slug: slug) ? storefront_path(slug) : root_path
      redirect_to destination, alert: "Facebook sign-in was cancelled or failed."
    end

    private

    def omniauth_seller_slug
      request.env.dig("omniauth.params", "seller_slug")
    end
  end
end
