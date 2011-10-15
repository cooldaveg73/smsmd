# == Schema Information
#
# Table name: notify_schemes
#
#  id         :integer(4)      not null, primary key
#  pm_id      :integer(4)
#  project_id :integer(4)
#  alert_type :string(24)
#  created_at :datetime
#  updated_at :datetime
#

class NotifyScheme < ActiveRecord::Base
  ALERT_TYPES = ["acc", "req", "fin", "alert"]
  belongs_to :project
  belongs_to :pm

  validates :alert_type,	:inclusion => { :in => ALERT_TYPES }
end

