class Customer < ApplicationRecord
  acts_as_tenant :seller

  devise :rememberable, :trackable, :omniauthable, omniauth_providers: [ :facebook ]

  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :uid, :provider, :name, presence: true
  validates :uid, uniqueness: { scope: [ :seller_id, :provider ] }

  # Finds or creates the tenant-scoped customer from the Facebook OAuth hash.
  #
  # Captured from Facebook on every login:
  #   auth.uid        -> uid        (the Facebook user ID)
  #   auth.info.name  -> name
  #   auth.info.email -> email      (may be absent if the user declined the
  #                                  email permission or has no email on file)
  #   auth.info.image -> avatar_url (stable Graph API picture URL,
  #                                  https://graph.facebook.com/<uid>/picture)
  def self.from_omniauth(auth, seller)
    customer = seller.customers.find_or_initialize_by(provider: auth.provider, uid: auth.uid)

    customer.name = auth.info.name if auth.info.name.present?
    # Don't wipe a known email/avatar if Facebook omits it on a later login
    customer.email = auth.info.email if auth.info.email.present?
    customer.avatar_url = picture_url_from(auth) if picture_url_from(auth).present?

    customer.save!
    customer
  end

  # Prefers the stable Graph API image URL; falls back to the raw_info
  # picture payload if the strategy didn't build one.
  def self.picture_url_from(auth)
    auth.info.image.presence || auth.extra&.dig("raw_info", "picture", "data", "url")
  end
  private_class_method :picture_url_from

  def default_address
    addresses.find_by(default: true) || addresses.first
  end
end
