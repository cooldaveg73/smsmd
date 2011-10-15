# == Schema Information
#
# Table name: pms
#
#  id         :integer(4)      not null, primary key
#  first_name :string(20)
#  last_name  :string(20)
#  mobile     :string(20)
#  active     :boolean(1)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Pm < ActiveRecord::Base

  belongs_to :user

  has_many :notify_schemes
  has_many :memberships,	:as => :person,
                                :dependent => :destroy
  has_many :projects,		:through => :memberships
  has_many :from_messages,	:class_name => "Message", :as => :from_person,
  				:dependent => :restrict
  has_many :to_messages,	:class_name => "Message", :as => :to_person,
  				:dependent => :restrict

  validates :first_name,	:length => { :maximum => 20 }
  validates :last_name, 	:length => { :maximum => 20 }
  validates :mobile, 		:length => { :maximum => 20 }

  def name; [first_name, last_name].join(" "); end;
  def full_name; [first_name, last_name].join(" "); end;

  # notify scheme types: [ "acc", "req", "fin", "alert" ]
  def self.notify(type, kase)
    kase.project.pms.each do |pm|
      query = "pm_id = ? AND alert_type = ?", pm.id, type
      unless kase.project.notify_schemes.where(*query).blank?
	send_info = { :msg => kase.send("#{type}_for_pm"), :case => kase }
	Message.send_to_person(pm, send_info)
      end
    end
  end

end
