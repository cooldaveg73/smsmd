# == Schema Information
#
# Table name: demoers
#
#  id          :integer(4)      not null, primary key
#  mobile      :string(255)
#  demoer_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  acc         :boolean(1)      default(FALSE)
#

class Demoer < ActiveRecord::Base
  @@types = [ "doctor", "vhd", "receiver" ]

  validates :mobile,		:presence => true
  validates :demoer_type,	:inclusion => { :in => @@types }
end

