class Invoice < ApplicationRecord
  acts_as_tenant :seller

  belongs_to :order

  enum :status, { draft: 0, issued: 1, paid: 2, void: 3 }

  validates :number, presence: true, uniqueness: { scope: :seller_id }
  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  before_validation :assign_number, on: :create

  def amount
    amount_cents / 100.0
  end

  private

  def assign_number
    self.number ||= "INV-#{Time.current.strftime('%Y')}-#{SecureRandom.alphanumeric(8).upcase}"
  end
end
