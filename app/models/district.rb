# == Schema Information
#
# Table name: districts
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class District < ActiveRecord::Base
  has_many :blocks
  has_and_belongs_to_many :pms

  validates :name,	:length => { :maximum => 255 }
  validates :state,	:length => { :maximum => 2 }, 
  			:inclusion => { :in => ['RJ', 'WB'] }
end
