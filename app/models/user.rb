class User < ActiveRecord::Base
  authenticates_with_sorcery!

  validates :password,                presence: true, confirmation: true, length: { minimum: 3 }, on: :create
  validates :password_confirmation,   presence: true, on: :create
  validates :email,                   presence: true, uniqueness: true

  has_many :listings, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :cards,    dependent: :destroy

  def name
    self.firstname + ' ' + self.lastname
  end

  def to_preact
    {
      :name => self.name,
      :email => self.email,
      :uid => self.id,
      :properties => {
        :created_at => self.created_at.to_i
      }
    }
  end

  def is_host?
    !listings.empty?
  end

  def is_admin?
    ['c@chrisbolton.me'].select {|e| email == e}
  end

  def self.hosts
    User.select{|u|!u.listings.empty?}
  end

end
