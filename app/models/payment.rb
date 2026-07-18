class Payment < ApplicationRecord
  acts_as_tenant :seller

  belongs_to :order

  enum :method, { card: 0, bank_transfer: 1, cash_on_delivery: 2, wallet: 3 }, prefix: :via
  enum :status, { pending: 0, succeeded: 1, failed: 2, refunded: 3 }

  validates :amount_cents, numericality: { greater_than: 0 }
  validates :reference, presence: true, uniqueness: { scope: :seller_id }

  before_validation :assign_reference, on: :create

  def amount
    amount_cents / 100.0
  end

  private

  def assign_reference
    self.reference ||= "PAY-#{SecureRandom.alphanumeric(10).upcase}"
  end
end
