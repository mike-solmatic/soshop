class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  validates :product_name, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  def line_total_cents
    quantity * unit_price_cents
  end

  def line_total
    line_total_cents / 100.0
  end

  def unit_price
    unit_price_cents / 100.0
  end
end
