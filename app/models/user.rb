class User < ActiveRecord::Base
  authenticates_with_sorcery!

  validates :password,                presence: true, confirmation: true, length: { minimum: 3 }
  validates :email,                   presence: true, uniqueness: true
  validates :password_confirmation,   presence: true

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

  def self.hosts
    User.select{|u|!u.listings.empty?}
  end

end
