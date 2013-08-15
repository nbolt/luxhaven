class ParagraphImage < ActiveRecord::Base
  mount_uploader :image, ParagraphImageUploader
  belongs_to :paragraph
end
