class Admin::SellersController < Admin::BaseController
  def index
    @sellers = Seller.recently_registered
                     .left_joins(:customers, :orders)
                     .select("sellers.*, COUNT(DISTINCT customers.id) AS customers_count, COUNT(DISTINCT orders.id) AS orders_count")
                     .group("sellers.id")
  end

  def show
    @seller = Seller.find(params[:id])
    ActsAsTenant.with_tenant(@seller) do
      @customers = @seller.customers.order(created_at: :desc)
      @orders_count = @seller.orders.count
      @revenue_cents = @seller.payments.succeeded.sum(:amount_cents)
      render :show
    end
  end

  def approve
    seller = Seller.find(params[:id])
    seller.approve!
    redirect_back fallback_location: admin_sellers_path, notice: "#{seller.store_name} approved."
  end

  def toggle_enabled
    seller = Seller.find(params[:id])
    seller.update!(enabled: !seller.enabled?)
    state = seller.enabled? ? "enabled" : "disabled"
    redirect_back fallback_location: admin_sellers_path, notice: "#{seller.store_name} #{state}."
  end
end
