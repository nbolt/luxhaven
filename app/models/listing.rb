class Listing < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :scoped, scope: :region_id

  validates :slug, presence: true

  before_create do
    self.region_id = address.region.id
  end

  belongs_to :user
  belongs_to :region
  has_many :bookings, dependent: :destroy
  has_many :images, dependent: :destroy
  has_one :address, dependent: :destroy

  def conflicts? check_in, check_out
    !!bookings.where(payment_status: 'charged').find do |booking|
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

  def slug_candidates
    [
      :title,
      [:title, :id]
    ]
  end
end
