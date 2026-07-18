module Portal
  class AddressesController < BaseController
    def index
      @addresses = current_customer.addresses.order(default: :desc, created_at: :asc)
    end

    def new
      @address = current_customer.addresses.new
    end

    def create
      @address = current_customer.addresses.new(address_params)
      if @address.save
        redirect_to portal_addresses_path, notice: "Address added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @address = current_customer.addresses.find(params[:id])
    end

    def update
      @address = current_customer.addresses.find(params[:id])
      if @address.update(address_params)
        redirect_to portal_addresses_path, notice: "Address updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      address = current_customer.addresses.find(params[:id])
      address.destroy
      redirect_to portal_addresses_path, notice: "Address removed."
    end

    def make_default
      address = current_customer.addresses.find(params[:id])
      address.make_default!
      redirect_to portal_addresses_path, notice: "Default address updated."
    end

    private

    def address_params
      params.expect(address: [ :label, :recipient, :line1, :line2, :city, :state, :postal_code, :country, :phone ])
    end
  end
end
