# == Schema Information
#
# Table name: panchayats
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  phc_id     :integer(4)
#  block_id   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Panchayat < ActiveRecord::Base
  has_many :villages
  belongs_to :phc
  belongs_to :block

  validates :name,	:length => { :maximum => 255 }
end
