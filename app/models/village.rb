# == Schema Information
#
# Table name: villages
#
#  id           :integer(4)      not null, primary key
#  name         :string(32)
#  panchayat_id :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

class Village < ActiveRecord::Base
  has_many :hospitals
  has_many :vhds
  belongs_to :panchayat

  validates :name,	:length => { :maximum => 32 }
end
