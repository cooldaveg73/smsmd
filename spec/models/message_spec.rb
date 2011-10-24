# == Schema Information
#
# Table name: messages
#
#  id                    :integer(4)      not null, primary key
#  incoming              :boolean(1)
#  msg                   :string(1024)
#  from_number           :string(20)
#  from_person_type      :string(8)
#  to_number             :string(20)
#  to_person_type        :string(8)
#  case_id               :integer(4)
#  time_received_or_sent :datetime
#  external_id           :string(255)
#  gateway_status        :string(255)
#  time_delivered        :datetime
#  created_at            :datetime
#  updated_at            :datetime
#  project_id            :integer(4)
#  from_person_id        :integer(4)
#  to_person_id          :integer(4)
#

require 'spec_helper'

describe Message do

  describe "model specs" do

    it "should create a message given valid attributes" do
      factories = [ :to_doctor_message, :from_doctor_message, 
        :to_vhd_message, :from_vhd_message ]
      (0...factories.length).each do |n|
	attributes = Factory.build(factories[n]).attributes
	Message.create(attributes).class.should == Message
      end
    end
  end

end


