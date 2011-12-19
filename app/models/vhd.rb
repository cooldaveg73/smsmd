# == Schema Information
#
# Table name: vhds
#
#  id         :integer(4)      not null, primary key
#  first_name :string(20)
#  last_name  :string(20)
#  mobile     :string(20)
#  status     :string(10)
#  notes      :string(1024)
#  village_id :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer(4)
#  phc_id     :integer(4)
#  is_patient :boolean(1)      default(FALSE)
#  doctor_id  :integer(4)
#  department :string(24)
#

class Vhd < ActiveRecord::Base
  VHD_STATI = %w(scribed vacant deactivated deleted)

  belongs_to :project
  belongs_to :phc
  belongs_to :user
  belongs_to :village
  belongs_to :doctor
  has_many :cases,		:dependent => :restrict
  has_many :from_messages,	:class_name => "Message", :as => :from_person,
  				:dependent => :restrict
  has_many :to_messages,	:class_name => "Message", :as => :to_person,
  				:dependent => :restrict
  
  validates :first_name, 	:length => { :maximum => 20 }, :presence => true
  validates :last_name, 	:length => { :maximum => 20 }, :presence => true
  validates :mobile, 		:length => { :maximum => 20 }, :presence => true
  validates :project,		:presence => true
  validates :status, 		:length => { :maximum => 24 },
  				:inclusion => { :in => VHD_STATI }
  validates :notes, 		:length => { :maximum => 1024 }

  def full_name; [first_name, last_name].join(" "); end;

  def name
    conditions = "first_name = ? AND project_id = ?"
    arguments = first_name, project.id
    return first_name if Vhd.where(conditions, *arguments).count == 1
    return full_name
  end

  def unfinished_cases
    unfinished_stati = ["accepted", "opened", "scribed"]
    cases.where("status IN (?)", unfinished_stati)
  end

  #def self.scribed_vhds_at(time)
  #  scribed_vhds = Vhd.where('status = "scribed"')
  #  Vhd.where('status = "scribed"').map do |vhd|
  #    last_message = vhd.messages_as_from_vhd.last
  #    vhd if last_message && last_message.time_sent < time
  #  end.compact
  #end

end
