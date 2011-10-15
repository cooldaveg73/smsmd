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


