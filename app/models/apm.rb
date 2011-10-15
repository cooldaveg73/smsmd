# == Schema Information
#
# Table name: apms
#
#  id         :integer(4)      not null, primary key
#  first_name :string(20)
#  last_name  :string(20)
#  mobile     :string(20)
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer(4)
#

class Apm < ActiveRecord::Base
  has_many :blocks
  belongs_to :project

  validates :first_name,	:length => { :maximum => 20 }
  validates :last_name,		:length => { :maximum => 20 }
  validates :mobile,		:length => { :maximum => 20 }
end
