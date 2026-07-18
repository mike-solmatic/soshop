class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def forbidden
    redirect_to root_path, alert: "You are not allowed to perform that action."
  end

  def not_found
    redirect_back fallback_location: root_path, alert: "Record not found."
  end

  # Devise redirect targets per scope
  def after_sign_in_path_for(resource)
    case resource
    when Seller   then resource.active? ? sellers_dashboard_path : sellers_pending_approval_path
    when Admin    then admin_dashboard_path
    when Customer then portal_dashboard_path
    else super
    end
  end
end
