# == Schema Information
#
# Table name: blocks
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  apm_id     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Block < ActiveRecord::Base
  belongs_to :apm
  has_many :panchayats

  validates :name,	:length => { :maximum => 255 }
end
