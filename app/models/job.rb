class Job < ActiveRecord::Base
  scope :active, -> { where(active: true) }

  has_many :about_qualifications, class_name: 'JobQualification', foreign_key: 'about_id'
  has_many :skill_qualifications, class_name: 'JobQualification', foreign_key: 'skills_id'
  has_many :responsibility_qualifications, class_name: 'JobQualification', foreign_key: 'responsibilities_id'
end
