module Portal
  class OrdersController < BaseController
    def index
      @orders = current_customer.orders.recent.includes(:order_items)
    end

    def show
      @order = current_customer.orders.includes(:shipping_address, :invoice, order_items: :product).find(params[:id])
      @payments = @order.payments.order(created_at: :desc)
    end
  end
end
