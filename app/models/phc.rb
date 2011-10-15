# == Schema Information
#
# Table name: phcs
#
#  id             :integer(4)      not null, primary key
#  name           :string(255)
#  contact_name   :string(255)
#  contact_number :string(20)
#  created_at     :datetime
#  updated_at     :datetime
#

class Phc < ActiveRecord::Base
  has_many :panchayats
  has_many :vhds
  has_many :projects,	:through => :vhds

  validates :name,		:length => { :maximum => 255 }
  validates :contact_name,	:length => { :maximum => 255 }
  validates :contact_number,	:length => { :maximum => 20 }
end
