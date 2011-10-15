# == Schema Information
#
# Table name: projects
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  has_reqs              :boolean(1)      default(FALSE)
#  has_hlps              :boolean(1)      default(FALSE)
#  include_doctor_name   :boolean(1)      default(TRUE)
#  include_doctor_mobile :boolean(1)      default(TRUE)
#  mobile                :string(24)      default("9223173098")
#  unregistered_msg      :string(1024)
#  close_msg             :string(1024)
#  format_msg            :string(1024)
#  timezone              :decimal(3, 1)
#  location              :string(24)
#

class Project < ActiveRecord::Base

  has_many :paging_schemes,	:dependent => :destroy
  has_many :notify_schemes,	:dependent => :destroy
  has_many :memberships,	:dependent => :destroy
  has_many :messages,		:dependent => :restrict
  has_many :cases, 		:dependent => :restrict
  has_many :phcs, 		:through => :vhds
  has_many :hospitals,		:through => :doctors

  has_many :doctors,	:dependent => :restrict
  has_many :vhds,	:dependent => :restrict
  has_many :patients,	:dependent => :restrict
  has_many :apms,	:dependent => :nullify
  has_many :pms,	:through => :memberships, 
  			:source => :person, :source_type => "Pm"
  has_many :users,	:through => :memberships,
  			:source => :person, :source_type => "User"

  validates :name,	:presence => true,
			:length => {:maximum => 20}
  validates :mobile,	:presence => true

  def get_doctors_to_page(kase)
    available_schemes = paging_schemes - kase.paging_schemes
    return [get_available_doctor] if available_schemes.blank?
    priority = available_schemes.first.priority
    usable_schemes = available_schemes.select { |s| s.priority == priority }
    return get_doctors_from_schemes(usable_schemes, kase.doctors_paged)
  end

  def get_available_doctor
    # return the doctor who was paged before any other doctor
    doctors.where('status = "available"').order("last_paged").map do |d|
      d if d.pageable?
    end.compact.first
  end

  private

    # TODO: comment the **** out of this function
    def get_doctors_from_schemes(schemes, doctors_paged=[])
      doctors_to_page = []
      schemes.each do |s| 
	doctor = s.get_doctor
	if doctor.nil? || doctors_paged.include?(doctor)
	  if s.random_doctor
	    saved_doctor_info = {}
	    saved_doctors = []
	    while true
	      saved_doctors << doctor
	      saved_paged_time = doctor.last_paged
	      saved_doctor_info[doctor.id] = { :last_paged => saved_paged_time }
	      temp_paged_time = DateTime.now.new_offset(0)
	      doctor.update_attributes(:last_paged => temp_paged_time)
	      next_doctor = get_available_doctor
	      break if next_doctor.nil? || saved_doctors.include?(next_doctor)
	      unless doctors_paged.include?(next_doctor)
		doctors_to_page << next_doctor
		break
	      end
	      doctor = next_doctor
	      # TODO: rescue that data
	    end
	  end
	else
	  doctors_to_page << doctor
	end
      end
      return doctors_to_page
    end

end

