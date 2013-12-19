class Venue < ActiveRecord::Base
	has_one :address
	belongs_to :region

end
