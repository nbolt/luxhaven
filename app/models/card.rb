class Card < ActiveRecord::Base
  belongs_to :user
  validates :fingerprint, uniqueness: { scope: :user_id }
end
