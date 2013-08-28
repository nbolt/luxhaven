class Feature < ActiveRecord::Base
  has_one :feature_type
  belongs_to :feature_group
  has_and_belongs_to_many :listings
  has_and_belongs_to_many :rooms
  validates_uniqueness_of :name
end
