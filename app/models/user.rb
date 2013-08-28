class User < ActiveRecord::Base
  authenticates_with_sorcery!

  validates :password,                presence: true, confirmation: true, length: { minimum: 3 }, on: :create
  validates :password_confirmation,   presence: true, on: :create
  validates :email,                   presence: true, uniqueness: true

  has_many :listings, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :cards,    dependent: :destroy

  def name
    firstname + ' ' + lastname
  end

  def is_host?
    !listings.empty?
  end

  def self.hosts
    User.select{|u|u.is_host?}
  end
end
