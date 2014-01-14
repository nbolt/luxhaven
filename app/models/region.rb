class Region < ActiveRecord::Base 

  extend FriendlyId
  friendly_id :name, use: :slugged

  mount_uploader :image, HeaderImageUploader
  
  has_many :addresses
  has_many :districts
  has_many :images

  validates :name, uniqueness: true

  def venues
    addresses.is_venue
  end
end
