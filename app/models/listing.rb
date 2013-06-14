class Listing < ActiveRecord::Base
  belongs_to :user
  belongs_to :region
  has_many :bookings
  has_many :images
  has_many :reservations
  has_one :address

  def self.available check_in, check_out, listings=Listing.all
    check_in  = Date.parse check_in  if check_in.is_a?  String
    check_out = Date.parse check_out if check_out.is_a? String

    listings.select do |listing|
      !listing.reservations.find do |reservation|
        check_in  <= reservation.check_out && check_in  >= reservation.check_in ||
        check_out <= reservation.check_out && check_out >= reservation.check_in ||
        check_in  <= reservation.check_in  && check_out >= reservation.check_out
      end
    end
  end
end
