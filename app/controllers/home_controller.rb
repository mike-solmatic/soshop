class HomeController < ApplicationController
  def index
    redirect_to after_sign_in_path_for(current_seller) and return if seller_signed_in?
    redirect_to admin_dashboard_path and return if admin_signed_in?
    redirect_to portal_dashboard_path and return if customer_signed_in?

    @demo_store = Seller.active.first
  end
end
