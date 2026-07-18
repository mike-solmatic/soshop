class Address < ApplicationRecord
  acts_as_tenant :seller

  belongs_to :customer

  validates :recipient, :line1, :city, :postal_code, :country, presence: true

  before_save :ensure_single_default

  def make_default!
    transaction do
      customer.addresses.where.not(id: id).update_all(default: false)
      update!(default: true)
    end
  end

  def to_s
    [ line1, line2, city, state, postal_code, country ].compact_blank.join(", ")
  end

  private

  # First address for a customer becomes the default automatically
  def ensure_single_default
    self.default = true if customer.addresses.where.not(id: id).none?
    customer.addresses.where.not(id: id).update_all(default: false) if default? && default_changed?
  end
end
