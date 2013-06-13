class Listing < ActiveRecord::Base
  belongs_to :user
  belongs_to :region
  has_many :bookings
  has_many :images
  has_one :address
end
