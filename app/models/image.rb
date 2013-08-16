class Image < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  belongs_to :listing
  belongs_to :room
end
