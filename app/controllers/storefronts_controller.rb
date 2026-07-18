# Public storefront page for a seller — where customers log in with Facebook.
class StorefrontsController < ApplicationController
  def show
    @seller = Seller.active.find_by!(slug: params[:slug])
    ActsAsTenant.with_tenant(@seller) do
      @products = @seller.products.active.order(:name)
      render :show
    end
  end
end
