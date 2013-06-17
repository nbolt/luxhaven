class Listing < ActiveRecord::Base
  belongs_to :user
  belongs_to :region
  has_many :bookings
  has_many :images
  has_one :address

  def conflicts? check_in, check_out
    !!bookings.where('payment_status != null').find do |booking|
      check_in  <  booking.check_out && check_in  >= booking.check_in ||
      check_out <= booking.check_out && check_out >  booking.check_in ||
      check_in  <= booking.check_in  && check_out >= booking.check_out
    end
  end

  def self.available check_in, check_out, listings=Listing.all
    check_in  = Date.parse check_in  if check_in.is_a?  String
    check_out = Date.parse check_out if check_out.is_a? String

    listings.select { |listing| !listing.conflicts?(check_in, check_out) }
  end
end
