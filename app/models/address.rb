class Address < ActiveRecord::Base
  belongs_to :region
  belongs_to :listing
  belongs_to :venue

  geocoded_by :full_address
  after_validation :geocode

  scope :is_venue, -> { where('venue_id is not null') }

  def full_address
    "#{street1} #{city} #{state} #{zip}"
  end
end
