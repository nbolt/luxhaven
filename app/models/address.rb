class Address < ActiveRecord::Base
  belongs_to :region
  belongs_to :listing
end
