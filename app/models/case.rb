# == Schema Information
#
# Table name: cases
#
#  id                      :integer(4)      not null, primary key
#  status                  :string(10)
#  followed_up             :boolean(1)
#  fake                    :boolean(1)
#  success                 :boolean(1)
#  alerted                 :boolean(1)
#  doctor_id               :integer(4)
#  vhd_id                  :integer(4)
#  patient_id              :integer(4)
#  time_opened             :datetime
#  time_accepted           :datetime
#  time_closed_or_resolved :datetime
#  last_message_time       :datetime
#  created_at              :datetime
#  updated_at              :datetime
#  project_id              :integer(4)
#  tag                     :integer(4)
#

class Case < ActiveRecord::Base
  CASE_STATI = ["accepted", "closed", "opened", "resolved", "scribed"]

  belongs_to :doctor
  belongs_to :vhd
  belongs_to :patient
  belongs_to :project
  has_many :messages,		:dependent => :restrict
  has_many :paging_records
  has_many :paging_schemes,	:through => :paging_records

  validates :status,	:length => { :maximum => 10 },
  			:inclusion => { :in => CASE_STATI }
  validates :vhd,	:presence => true
  validates :patient,	:presence => true
  validates :project,	:presence => true

  alias_attribute :time_closed, :time_closed_or_resolved
  alias_attribute :time_resolved, :time_closed_or_resolved

  def last_doctor_msg
    return "" if doctor.nil?
    query = "from_person_type = ? AND from_person_id = ?", "Doctor", doctor.id
    last_message = messages.where(*query).last
    return "" if last_message.nil?
    return Code.expand(last_message.msg)
  end
  
  def fin_sms
    return "" if doctor.nil?
    query = "from_person_type = ? AND from_person_id = ?", "Doctor", doctor.id
    last_message = messages.where(*query).last
    return "" if last_message.nil?
    message_words = last_message.msg.strip.split(/\s+/)
    return "" unless message_words[0].match(/fin/i)
    return Code.expand(last_message.msg, true)
  end

  def alert_for_pm
    message = [ "ALERT. No doctor has responded to case #{tag}:", 
    		complaint, "Doctors paged: "].join(" ")
    message += doctors_paged.map { |doctor| doctor.name }.join(", ")
    return message
  end

  def acc_reminder
    return [ "Reminder: please send your reply for patient",
             patient.name, patient.age, complaint ].join(" ")
  end

  def handle_case_with_acc(doctor)
    self.status = "accepted"
    self.time_accepted = DateTime.now.new_offset(0)
    self.doctor = doctor
    self.save
    doctor.update_attributes(:status => "accepted")
    doctor.unclosed_cases.each { |c| c.reopen unless c == self }
    send_info = { :case => self }
    Message.send_to_person(doctor, send_info.merge(:msg => acc_for_doctor))
    Pm.notify("acc", self)
    unless vhd.is_patient
      Message.send_to_person(vhd, send_info.merge(:msg => acc_for_vhd))
    else
      Message.send_to_person(vhd, send_info.merge(:msg => acc_for_patient))
    end
  end

  def unavailable_response
    return "This case has now been closed." if status == "closed"
    return "This case has now been resolved." if status == "resolved"
    return "Another doctor has accepted this case." if status == "accepted"
    return "Another doctor is working on this case." if status == "scribed"
  end

  def self.new_case_from_vhd(vhd, patient)
    create(:status => "opened", :vhd => vhd, :patient => patient, 
      :time_opened => DateTime.now.new_offset(0), :project => vhd.project,
      :tag => vhd.project.cases.count + 1)
  end

  def doctors_paged
    messages.where('to_person_type = "Doctor"').map { |m| m.to_person }
  end
  
  def opening_message
    return nil if messages.empty?
    return messages.order("time_received_or_sent, id").first
  end

  def req_for_pm
    return ["From VHD", vhd.name, vhd.mobile + ":", 
      opening_message.msg, "- case #{tag}"].join(" ")
  end

  def acc_for_doctor
    return [ "Thank you, Dr. #{doctor.last_name}.",
      "Please respond to the following case:", patient.name, 
      patient.age_string, vhd.mobile, complaint ].join(" ")
  end

  def acc_for_vhd
    msg = "ACC for patient #{patient.name}"
    if project.include_doctor_name? || project.include_doctor_mobile?
      msg += " - Dr. "
      msg += doctor.name if project.include_doctor_name?
      msg += doctor.mobile if project.include_doctor_mobile?
    end
    msg += doctor.hospital.name unless doctor.hospital.nil?
    return msg
  end
  
  def acc_for_pm
    return ["ACC - Dr.", doctor.name, doctor.mobile, 
      ": case #{tag}" ].compact.join(" ")
  end

  def acc_for_patient
    return ["Dr.", doctor.last_name, doctor.mobile,
      "has accepted your case."].compact.join(" ")
  end

  def fin_for_vhd
    return "" if fin_sms.blank?
    return ["For patient", patient.name, "FIN", fin_sms, "-", 
      "Dr.", doctor.name, doctor.mobile].compact.join(" ")
  end

  def fin_for_pm
    return ["For patient", patient.name, "FIN", fin_sms, "-", 
      "Dr.", doctor.name, doctor.mobile, ": case #{tag}" ].compact.join(" ")
  end

  def send_close_message
    close_message =     if messages.where("msg = ?", close_message).blank?
      if project.vhd_based?
        Message.send_to_vhd(vhd, close_message, self)
      elsif project.patient_based?
        Message.send_to_patient(patient, close_message, self)
      end
    end
  end

  def close
    # DEFAULT_CLOSE_MSG.gsub("|PATIENT|", patient.name)
    unless doctor.nil? || doctor.status != "accepted"
      if doctor.current_case == (self || nil)
	doctor.update_attributes(:status => "available")
      end
    end
    time_closed = DateTime.now.new_offset(0)
    update_attributes(:status => "closed", :time_closed => time_closed)
  end

  def resolve
    time_resolved = DateTime.now.new_offset(0)
    update_attributes(:status => "resolved", :time_resolved => time_resolved)
  end

  def reopen
    update_attributes(:status => "opened", :time_accepted => nil,
      :time_closed_or_resolved => nil)
  end

  def complaint
    return "" if opening_message.nil? || project.nil?
    message_words = opening_message.msg.strip.split(/\s+/)
    if message_words[0].match(/req/i) && project.has_reqs
      return message_words[5...message_words.length].join(" ")
    elsif message_words[0].match(/hlp/i) && project.has_hlps
      return message_words[1...message_words.length].join(" ")
    end
  end

end
