module Portal
  class BaseController < ApplicationController
    layout "portal"

    before_action :authenticate_customer!
    set_current_tenant_through_filter
    before_action :set_tenant

    private

    # The customer portal is scoped to the tenant (seller) the customer belongs to.
    def set_tenant
      set_current_tenant(current_customer.seller)
    end
  end
end
