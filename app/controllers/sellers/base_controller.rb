module Sellers
  class BaseController < ApplicationController
    layout "seller"

    before_action :authenticate_seller!
    before_action :require_active_seller!
    set_current_tenant_through_filter
    before_action :set_tenant

    private

    # Every query in the seller area is scoped to the signed-in seller's rows.
    def set_tenant
      set_current_tenant(current_seller)
    end

    def require_active_seller!
      return if current_seller.active?

      redirect_to sellers_pending_approval_path
    end
  end
end
