class Admin::DashboardController < Admin::BaseController
  def show
    @latest_sellers  = Seller.recently_registered.limit(6)
    @pending_sellers = Seller.pending.recently_registered

    @active_sellers_count  = Seller.active.count
    @pending_sellers_count = Seller.pending.count
    @total_customers = Customer.unscoped.count
    @total_orders    = Order.unscoped.count

    @chart_data = (13.days.ago.to_date..Date.current).map do |day|
      {
        label: day.strftime("%b %-d"),
        orders: Order.unscoped.where(placed_at: day.all_day).count,
        revenue: Payment.unscoped.where(status: :succeeded, paid_at: day.all_day).sum(:amount_cents) / 100.0
      }
    end
  end
end
