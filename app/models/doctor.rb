# == Schema Information
#
# Table name: doctors
#
#  id               :integer(4)      not null, primary key
#  first_name       :string(20)
#  last_name        :string(20)
#  mobile           :string(20)
#  status           :string(10)
#  last_paged       :datetime
#  specialty        :string(20)
#  hospital_id      :integer(4)
#  active           :boolean(1)
#  user_id          :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#  project_id       :integer(4)
#  points           :integer(4)      default(0)
#  points_timestamp :datetime
#

class Doctor < ActiveRecord::Base
  DOCTOR_STATI = %w(available accepted opened scribed deactivated deleted)

  belongs_to :project
  belongs_to :hospital
  belongs_to :user
  has_many :cases,		:dependent => :restrict
  has_many :vhds,		:dependent => :nullify
  has_many :shifts,		:dependent => :destroy
  has_many :from_messages,	:class_name => "Message", :as => :from_person,
  				:dependent => :restrict
  has_many :to_messages,	:class_name => "Message", :as => :to_person,
  				:dependent => :restrict

  validates :first_name,	:length => { :maximum => 20 }, :presence => true
  validates :last_name, 	:length => { :maximum => 20 }, :presence => true
  validates :mobile, 		:length => { :maximum => 20 }, :presence => true
  validates :status, 		:length => { :maximum => 24 },
				:inclusion => { :in => DOCTOR_STATI }
  validates :project,		:presence => true
  validates :specialty, 	:length => { :maximum => 20 }
  validates :last_paged,	:presence => true

  def current_case
    current_cases = cases.where('status = "accepted" OR status = "scribed"')
    # TODO: cases.count > 1
    return nil if current_cases.count != 1
    return current_cases.last
  end

  def next_open_case
    return nil if open_cases.blank?
    open_cases.sort_by { |kase| kase.time_opened }.last
  end

  def full_name; [ first_name, last_name ].join(" "); end;

  def name
    query = "last_name = ? AND project_id = ?"
    args = last_name, project.id
    return last_name if Doctor.where(query, *args).count == 1
    new_name = [first_name.first, last_name].join(" ")
    query = "first_name LIKE ? AND last_name = ? AND project_id = ?"
    args = first_name.first + "%", last_name, project.id
    return new_name if Doctor.where(query, *args).count == 1
    return full_name
  end

  def acc_options
    return nil if open_cases.blank?
    options = "The following cases are available: "
    acc_arr = []
    open_cases.each { |kase| acc_arr << "ACC #{letter_on_case(kase)}" }
    options += acc_arr.join(", ")
    return options + "."
  end

  def unclosed_cases
    cases.where('status = "accepted" OR status = "scribed"')
  end

  def pageable?
    ten_minutes_ago = DateTime.now.new_offset(0) - 10.minutes
    return status == ("available" || "opened") && last_paged < ten_minutes_ago
  end

  def page(kase)
    update_attributes(:status => "opened")
    send_info = { :msg => page_msg(kase), :case => kase }
    Message.send_to_person(self, send_info)
  end

  def page_msg(kase, letter=nil)
    return nil if kase.nil?
    letter = next_letter if letter.nil?
    message = ["Reply ACC #{letter} to accept case:",
      kase.patient.name, kase.patient.age_string, kase.complaint ].join(" ")
  end

  def next_letter
    letter = "A"
    num_cases = paged_cases_from_today.count
    num_cases.times { letter = letter.next }
    return letter
  end

  def case_on_letter(letter)
    return nil if letter.blank?
    paged_messages_from_today.each do |mess|
      return mess.case if mess.msg == page_msg(mess.case, letter)
    end
    return nil
  end

  def letter_on_case(kase)
    return nil if kase.blank?
    num_cases = paged_cases_from_today.count
    paged_messages_from_today.each do |mess|
      if mess.case == kase
	letter = "A"
	num_cases.times do
	  return letter if mess.msg == page_msg(kase, letter)
	  letter = letter.next
	end
      end
    end
    return nil
  end

  private

    def open_cases
      open_cases = paged_cases_from_today.map do |kase|
	kase.status == "opened" ? kase : nil
      end.compact
    end

    def paged_cases_from_today
      paged_messages_from_today.map { |mess| mess.case }.uniq
    end

    def paged_messages_from_today
      time = DateTime.now.new_offset(+5.5/24).beginning_of_day.utc.to_datetime
      msg_conditions = "time_received_or_sent > ? AND case_id IS NOT NULL"
      to_messages.where(msg_conditions, time)
    end

end
