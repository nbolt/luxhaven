class District < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :scoped, scope: :region_id

  belongs_to :region
  has_many :listings

  def slug_candidates
    :name
  end
end
