# == Schema Information
#
# Table name: patients
#
#  id         :integer(4)      not null, primary key
#  first_name :string(20)
#  last_name  :string(20)
#  age        :integer(4)
#  meta_age   :string(255)
#  mobile     :string(20)
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer(4)
#

class Patient < ActiveRecord::Base
  belongs_to :doctor
  belongs_to :project
  has_many :cases,			:dependent => :restrict
  has_many :messages_as_from_patient, 	:class_name => "Message",
                                      	:foreign_key => :from_patient_id,
					:dependent => :restrict
  has_many :messages_as_to_patient, 	:class_name => "Message",
                                    	:foreign_key => :to_patient_id,
					:dependent => :restrict

  validates :first_name, 	:length => { :maximum => 20 }
  validates :last_name, 	:length => { :maximum => 20 }
  validates :meta_age, 		:length => { :maximum => 255 }
  validates :mobile,		:length => { :maximum => 20 }

  def name; [first_name, last_name].join(" "); end;

  def age_string
    return (age.to_s + "y") unless age.nil?
    return meta_age unless meta_age.nil?
    # TODO
    return ""
  end

  def messages
    message_conditions = "from_patient_id = :id OR to_patient_id = :id"
    return Message.where(message_conditions, :id => id)
  end

end
