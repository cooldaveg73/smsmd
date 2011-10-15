# == Schema Information
#
# Table name: hospitals
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  village_id :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Hospital < ActiveRecord::Base
  has_many :doctors,	:dependent => :nullify
  has_many :projects,	:through => :doctors
  belongs_to :village
end
