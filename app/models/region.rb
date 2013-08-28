class Region < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  mount_uploader :image, HeaderImageUploader
  
  has_many :addresses

  validates :name, uniqueness: true
end
