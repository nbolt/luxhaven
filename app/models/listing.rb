class Listing < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :scoped, scope: :region_id

  serialize :unlisted_dates

  validates :slug, presence: true

  before_save { self.region_id = address.region.id }

  mount_uploader :search_image, SearchImageUploader
  mount_uploader :header_image, HeaderImageUploader

  belongs_to :user
  belongs_to :district
  has_and_belongs_to_many :features
  has_many :bookings, -> { order(:check_in) }, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :paragraphs, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_one :address, dependent: :destroy

  def conflicts? check_in, check_out
    !!bookings.charged.find do |booking|
      check_in  <  booking.check_out && check_in  >= booking.check_in ||
      check_out <= booking.check_out && check_out >  booking.check_in ||
      check_in  <= booking.check_in  && check_out >= booking.check_out
    end
  end

  def self.available check_in, check_out, listings=Listing.all
    check_in  = Time.at check_in.to_i  if check_in.is_a?  String
    check_out = Time.at check_out.to_i if check_out.is_a? String

    listings.select { |listing| !listing.conflicts?(check_in, check_out) }
  end

  def slugs
    "#{address.region.slug}/#{slug}"
  end

  def slug_candidates
    [
      :title,
      [:title, :id]
    ]
  end

  def self.price listings=Listing.all
    listings.sort_by(&:price_per_night)
  end

  def self.recommended listings=Listing.all
    # a pretty lame algorithm that pushes the following listings towards the top:
    #   - listings with the most availability in the next six months
    #   - listings with the smallest availability windows (from the host's side) in the next six months
    listings.sort_by do |listing|
      (listing.bookings.charged.select { |booking|
        booking.check_in >= Date.today && booking.check_out <= Date.today + 180.days
      }.map { |booking|
        (booking.check_out - booking.check_in).to_i
      }.reduce(:+) || 0) / 180.0 * (180 - (!listing.unlisted_dates && 0 || listing.unlisted_dates.select{ |date|
        date >= Date.today.to_time.to_i && date <= (Date.today + 180.days).to_time.to_i
      }.count) / 180.0)
    end
  end
end
