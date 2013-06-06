class User < ActiveRecord::Base
  authenticates_with_sorcery!

  validates :password,                presence: true, confirmation: true, length: { minimum: 3 }
  validates :email,                   presence: true, uniqueness: true
  validates :password_confirmation,   presence: true

  has_many :listings

  def name
    self.first_name + ' ' + self.last_name
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
end
