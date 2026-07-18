class Product < ApplicationRecord
  acts_as_tenant :seller

  has_many :order_items, dependent: :nullify

  validates :name, :category, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  def price
    price_cents / 100.0
  end
end
