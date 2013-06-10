class Listing < ActiveRecord::Base
  belongs_to :user
  belongs_to :region
  has_many :bookings
end
