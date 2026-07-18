module Portal
  class DashboardController < BaseController
    def show
      @orders = current_customer.orders.recent.limit(5)
      @orders_count = current_customer.orders.count
      @addresses_count = current_customer.addresses.count
      @default_address = current_customer.default_address
    end
  end
end
