class Seller < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :trackable, :lockable

  enum :status, { pending: 0, approved: 1 }

  has_many :customers, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :products, dependent: :destroy

  validates :name, :store_name, presence: true
  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers and dashes" }

  before_validation :generate_slug, on: :create

  scope :recently_registered, -> { order(created_at: :desc) }
  scope :active, -> { approved.where(enabled: true) }

  # Devise: block sign-in for disabled sellers (pending sellers may sign in
  # but see a "waiting for approval" screen)
  def active_for_authentication?
    super && enabled?
  end

  def inactive_message
    enabled? ? super : :account_disabled
  end

  def approve!
    update!(status: :approved, approved_at: Time.current)
  end

  def active?
    approved? && enabled?
  end

  private

  def generate_slug
    return if slug.present? || store_name.blank?

    base = store_name.parameterize
    candidate = base
    n = 2
    while Seller.exists?(slug: candidate)
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end
end
