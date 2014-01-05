class FaqTopic < ActiveRecord::Base
  belongs_to :faq_section
  has_many :faqs
end
