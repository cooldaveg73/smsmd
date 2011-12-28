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
#  unregistered_msg      :string(1024)    default("You have not been registered into the system. Please contact your hospital or project manager for registration.")
#  close_msg             :string(1024)    default("Ye Case, Patient |PATIENT| ki liye, bund hogaya. Apko kisi karan is case ka jawab nahi mile aur abhi bhi jewab ke jerurat he tho dubara REQ ka sms kare.")
#  req_format_msg        :string(1024)    default("Sorry, wrong format. Please re-send in this way: REQ (patient good name) (patient surname) (patient age (40y, A, C, I, E, P)) (patient mobile) (patient symptoms)")
#  time_zone             :decimal(3, 1)
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
  has_one :promoter

  validates :name,	:presence => true,
			:length => {:maximum => 20}
  validates :mobile,	:presence => true

  def get_doctors_to_page(kase)
    available_schemes = paging_schemes - kase.paging_schemes
    if available_schemes.blank?
      return [get_available_doctor(kase.doctors_paged)].compact
    end
    priority = available_schemes.first.priority
    usable_schemes = available_schemes.select { |s| s.priority == priority }
    kase.paging_schemes += usable_schemes
    return get_doctors_from_schemes(usable_schemes, kase.doctors_paged).compact
  end

  def get_available_doctor(doctors_paged=[])
    # return the doctor who was paged before any other doctor
    query = 'status = "available"'
    available_doctors = doctors.where(query).order("last_paged")
    (available_doctors - doctors_paged).map do |d|
      d if d.pageable?
    end.compact.first
  end

  private

    def get_doctors_from_schemes(schemes, doctors_paged=[])
      doctors_to_page = []
      schemes.each do |s| 
	doctor = s.get_doctor(doctors_paged)
	doctors_to_page << doctor unless doctor.nil?
	doctors_paged << doctor unless doctor.nil?
      end
      return doctors_to_page
    end

end

