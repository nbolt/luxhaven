class FaqSection < ActiveRecord::Base
  has_many :faq_topics
end
