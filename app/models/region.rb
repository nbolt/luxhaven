class Region < ActiveRecord::Base 

  extend FriendlyId
  friendly_id :name, use: :slugged

  mount_uploader :image, HeaderImageUploader
  
  has_many :addresses
  has_many :districts
  has_many :venues

  validates :name, uniqueness: true
end
