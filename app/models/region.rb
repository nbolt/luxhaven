class Region < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  has_many :addresses

  validates :name, uniqueness: true
end
