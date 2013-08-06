class Address < ActiveRecord::Base
  belongs_to :region
  belongs_to :listing

  geocoded_by :full_address
  after_validation :geocode

  def full_address
    "#{street1} #{city} #{state} #{zip}"
  end

  def display_neighborhood
    if neighborhood
      "#{neighborhood}, #{city}"
    else
      "#{city}, #{county}"
    end
  end
end
