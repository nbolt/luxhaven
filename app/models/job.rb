class Job < ActiveRecord::Base
  scope :active, -> { where(active: true) }
end
