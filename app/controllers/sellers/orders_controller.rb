module Sellers
  class OrdersController < BaseController
    def index
      @orders = Order.recent.includes(:customer, :payments)
      @orders = @orders.where(status: params[:status]) if params[:status].present? && Order.statuses.key?(params[:status])
    end

    def show
      @order = Order.includes(:customer, :shipping_address, :invoice, order_items: :product).find(params[:id])
      @payments = @order.payments.order(created_at: :desc)
    end
  end
end
