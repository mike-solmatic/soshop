class Order < ApplicationRecord
  acts_as_tenant :seller

  belongs_to :customer
  belongs_to :shipping_address, class_name: "Address", optional: true
  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_one :invoice, dependent: :destroy

  enum :status, { pending: 0, processing: 1, shipped: 2, delivered: 3, cancelled: 4 }

  validates :number, presence: true, uniqueness: { scope: :seller_id }
  validates :placed_at, presence: true

  before_validation :assign_number, on: :create

  scope :recent, -> { order(placed_at: :desc) }

  def total
    total_cents / 100.0
  end

  def subtotal
    subtotal_cents / 100.0
  end

  def shipping
    shipping_cents / 100.0
  end

  def paid_amount_cents
    payments.succeeded.sum(:amount_cents)
  end

  def fully_paid?
    paid_amount_cents >= total_cents
  end

  private

  def assign_number
    self.number ||= "ORD-#{Time.current.strftime('%Y%m')}-#{SecureRandom.alphanumeric(6).upcase}"
    self.placed_at ||= Time.current
  end
end
