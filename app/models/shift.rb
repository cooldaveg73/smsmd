# == Schema Information
#
# Table name: shifts
#
#  id           :integer(4)      not null, primary key
#  start_hour   :integer(4)
#  start_minute :integer(4)
#  start_second :integer(4)
#  end_hour     :integer(4)
#  end_minute   :integer(4)
#  end_second   :integer(4)
#  doctor_id    :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

class Shift < ActiveRecord::Base
  belongs_to :doctor

  # TODO: current function incomplete
  def self.doctors_available_at(time)
    return Doctor.all
  end
end
