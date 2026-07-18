module Sellers
  class DashboardController < BaseController
    def show
      @new_orders_count    = Order.where(placed_at: 7.days.ago..).count
      @new_customers_count = Customer.where(created_at: 7.days.ago..).count
      @revenue_cents_30d   = Payment.succeeded.where(paid_at: 30.days.ago..).sum(:amount_cents)
      @pending_orders      = Order.pending.count

      @recent_orders    = Order.recent.includes(:customer).limit(8)
      @recent_customers = Customer.order(created_at: :desc).limit(5)

      @chart_data = (13.days.ago.to_date..Date.current).map do |day|
        {
          label: day.strftime("%b %-d"),
          orders: Order.where(placed_at: day.all_day).count,
          revenue: Payment.succeeded.where(paid_at: day.all_day).sum(:amount_cents) / 100.0
        }
      end
    end
  end
end
