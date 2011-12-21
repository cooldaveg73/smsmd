# == Schema Information
#
# Table name: promoters
#
#  id           :integer(4)      not null, primary key
#  name         :string(128)
#  organization :string(32)
#  industry     :string(32)
#  country      :string(32)
#  website      :string(1024)
#  email        :string(128)
#  username     :string(24)
#  created_at   :datetime
#  updated_at   :datetime
#

class Promoter < ActiveRecord::Base
  validates :name,	:length => { :minimum => 5, :maximum => 128 }
  validates :email,	:presence => true
  validates_presence_of :organization, :country
end
