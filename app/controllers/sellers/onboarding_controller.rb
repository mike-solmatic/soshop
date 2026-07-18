module Sellers
  class OnboardingController < ApplicationController
    before_action :authenticate_seller!

    def pending_approval
      redirect_to sellers_dashboard_path if current_seller.active?
    end
  end
end
