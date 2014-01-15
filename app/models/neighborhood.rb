class Neighborhood < ActiveRecord::Base
  has_many :addresses

  def venues
    addresses.is_venue
  end
end
