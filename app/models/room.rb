class Room < ActiveRecord::Base
  belongs_to :listing
  has_many :images
  has_and_belongs_to_many :features
end
