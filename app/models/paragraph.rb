class Paragraph < ActiveRecord::Base
  has_one :image, dependent: :destroy, class_name: 'ParagraphImage'
  belongs_to :listing
  validates :order, presence: true, uniqueness: true
end
