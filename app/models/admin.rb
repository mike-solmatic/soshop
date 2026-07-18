class Admin < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable,
         :validatable, :trackable, :lockable

  validates :name, presence: true
end
