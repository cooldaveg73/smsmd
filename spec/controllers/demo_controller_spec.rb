require 'spec_helper'

describe DemoController do

  describe "sample demo" do
    before(:all) do
      @vhd = Factory(:vhd_demoer)
      @doctor = Factory(:doctor_demoer)
      @receiver = Factory(:receiver_demoer)
    end

    before(:each) do
      @doctor.update_attributes(:acc => false)
    end

    it "should reject an invalid REQ msg from a VHD" do
      args = [:mobile => @vhd.mobile, :text => "random text"]
      get :new, *args
      response.code.should == "200"
    end

    # NOTE: this takes three minutes to run
    #it "should accept a valid REQ msg from a VHD" do
    #  get :new, :mobile => @vhd.mobile, :text => random_req_msg
    #end

    it "should accept an ACC A from a doctor" do
      args = [:mobile => @doctor.mobile, :text => "ACC A"]
      get :new, *args
      @doctor.reload.acc.should == true
    end

    it "should accept an ACC from a doctor" do
      args = [:mobile => @doctor.mobile, :text => "ACC"]
      get :new, *args
      @doctor.reload.acc.should == true
    end

    it "should accept a FIN from a doctor who has ACC'd" do
      @doctor.update_attributes(:acc => true)
      args = [:mobile => @doctor.mobile, :text => "FIN dok dukhatey"]
      get :new, *args
      @doctor.reload.acc.should == false
    end

    it "should accept a SCRIBED from a doctor who has ACC'd" do
      @doctor.update_attributes(:acc => true)
      args = [:mobile => @doctor.mobile, :text => "I have a question. Okay?"]
      get :new, *args
      @doctor.reload.acc.should == true
    end

    it "should reject a FIN from a doctor who has not ACC'd" do
      args = [:mobile => @doctor.mobile, :text => "FIN dok dukhatey" ]
      get :new, *args
      @doctor.reload.acc.should == false
    end

  end
end
