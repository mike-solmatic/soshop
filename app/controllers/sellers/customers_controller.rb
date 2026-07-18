module Sellers
  class CustomersController < BaseController
    def index
      @customers = Customer.order(created_at: :desc)
                           .left_joins(:orders)
                           .select("customers.*, COUNT(orders.id) AS orders_count, COALESCE(SUM(orders.total_cents), 0) AS lifetime_cents")
                           .group("customers.id")
    end

    def show
      @customer = Customer.find(params[:id])
      @orders = @customer.orders.recent.includes(:payments)
    end
  end
end
