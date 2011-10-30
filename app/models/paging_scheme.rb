# == Schema Information
#
# Table name: paging_schemes
#
#  id            :integer(4)      not null, primary key
#  project_id    :integer(4)
#  priority      :integer(4)
#  doctor_id     :integer(4)
#  random_doctor :boolean(1)      default(TRUE)
#  created_at    :datetime
#  updated_at    :datetime
#

class PagingScheme < ActiveRecord::Base
  belongs_to :project
  belongs_to :doctor

  validates :priority,	:presence => true
  validates :project,	:presence => true

  default_scope :order => "paging_schemes.priority" 

  def get_doctor(doctors_paged=[])
    if doctor.pageable?
      return doctor
    elsif random_doctor
      return project.get_available_doctor(doctors_paged)
    end
  end
end
