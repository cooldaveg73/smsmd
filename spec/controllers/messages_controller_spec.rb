require 'spec_helper'

describe MessagesController do

  it "should send an unregistered message for an unregistered sender" do
    mobile = random_mobile
    post :sms_responder, :msisdn => mobile, :content => "no content"
    Message.last.to_number.should == mobile
    Message.last.msg.should == DEFAULT_UNREGISTERED_MSG
  end

  it "should redirect to the demo when posting with a demoer" do
    mobile = Factory(:vhd_demoer).mobile
    text = "XXX"
    post :sms_responder, :msisdn => mobile, :content => text
    response.code.should == "302"
    response.should redirect_to("/handle_demoer?mobile=#{mobile}&text=#{text}")
  end

  it "should send a custom unregistered_msg when paged with a location" do
    custom_msg = random_lorem
    location = random_lorem(1, 1)
    project = Factory(:project, :unregistered_msg => custom_msg, 
      :location => location)
    post :sms_responder, :msisdn => random_mobile, :content => random_lorem,
      :location => location
    Message.last.msg.should == custom_msg
  end

  describe "default project with req" do

    before(:all) do
      @project = Factory(:project, :has_reqs => true)
      @pm = Factory(:pm, :projects => [ @project ])
      @doctors, @vhds = [], []
      10.times { @doctors << Factory(:doctor, :project => @project) }
      10.times { @vhds << Factory(:vhd, :project => @project) }
    end

    before(:each) do
      @doctors.each { |d| d.update_attributes(:status => "available") }
      @vhds.each { |v| v.update_attributes(:status => "vacant") }
      @vhd = @vhds[rand(@vhds.count)]
    end
     
    describe "REQ" do

      before(:each) { @req_msg = random_req_msg }

      it "should create a new case with a valid format" do 
        lambda do
	  post :sms_responder, :msisdn => @vhd.mobile, :content => @req_msg
	end.should change(Case, :count)
      end

      it "should not create a new case with an invalid format" do
        lambda do
	  post :sms_responder, :msisdn => @vhd.mobile, :content => random_lorem
	end.should_not change(Case, :count)
      end

      it "should page a random doctor if there is no paging scheme" do
	post :sms_responder, :msisdn => @vhd.mobile, :content => @req_msg
	kase = @vhd.cases.last
	kase.opening_message.msg.should == @req_msg
	kase.doctors_paged.count.should == 1
      end

      it "should notify a pm" do
        NotifyScheme.create(:pm => @pm, :project => @project,
	  :alert_type => "req")
	post :sms_responder, :msisdn => @vhd.mobile, :content => @req_msg
	kase = @vhd.cases.last
	kase.opening_message.msg.should == @req_msg
	query = "to_person_type = ? AND to_person_id = ?", "Pm", @pm.id
	kase.messages.where(*query).should_not == []
      end

      it "should use the paging scheme with priority 1 first" do
        doctor_one = @doctors[rand(@doctors.count)]
	doctor_two = @doctors[rand(@doctors.count)]
        PagingScheme.create(:project => @project, :priority => 1, 
	  :doctor => doctor_one)
	PagingScheme.create(:project => @project, :priority => 1, 
	  :doctor => doctor_two)
	post :sms_responder, :msisdn => @vhd.mobile, :content => @req_msg
	kase = @vhd.cases.last
	kase.opening_message.msg.should == @req_msg
	to_doctor_messages = kase.messages.where('to_person_type = "Doctor"') 
	to_doctor_messages.count.should == 2
	doc_array = [ doctor_one.id, doctor_two.id ].sort
	to_doctor_messages.map { |a| a.to_person_id }.sort.should == doc_array
      end

      it "should generate ACC A" do
	post :sms_responder, :msisdn => @vhd.mobile, :content => @req_msg
	kase = @vhd.cases.last
	kase.opening_message.msg.should == @req_msg
	kase.doctors_paged.should_not == []
	kase.doctors_paged.each do |doctor|
	  doctor.case_on_letter("A").should == kase
	end
      end

      it "should create a new patient" do
	lambda do
	  post :sms_responder, :msisdn => @vhd.mobile, :content => @req_msg
	end.should change(Patient, :count)
      end

    end

    describe "ACC" do

      before(:each) do
        @case = Factory(:newly_opened_case, :vhd => @vhd )
	@doctors.shuffle!
	(0..3).each do |num|
	  Factory(:page_message, :to_person => @doctors.pop, :case => @case,
	          :time_sent => @case.time_opened + num.minutes)
	end
        @doctors_paged = @case.doctors_paged
	@doctors_paged.should_not == []
        @doctor = @doctors_paged[rand(@doctors_paged.count)]
      end

      after(:each) { @doctors_paged.each { |doctor| @doctors << doctor } }

      it "should page the doctor for a case with a valid ACC A" do
	lambda do
	  lambda do
	    post :sms_responder, :msisdn => @doctor.mobile, :content => "ACC A"
	  end.should change(@doctor.to_messages, :count)
	end.should change(@case.messages, :count)
      end

      it "should page the doctor for a case with a valid ACC B" do
        new_case = Factory(:newly_opened_case)
	Factory(:page_message, :to_person => @doctor, :case => new_case,
	        :time_sent => new_case.time_opened)
        lambda do
	  lambda do
	    post :sms_responder, :msisdn => @doctor.mobile, :content => "ACC B"
	  end.should change(@doctor.to_messages, :count)
	end.should change(new_case.messages, :count)
      end

      it "should page doctor with open cases with an invalid ACC X" do
	lambda do
	  lambda do
	    post :sms_responder, :msisdn => @doctor.mobile, :content => "ACC D"
	  end.should change(@doctor.to_messages, :count)
	end.should_not change(@case.messages, :count)
	last_message = @doctor.to_messages.last
	last_message.msg.match(/ACC A/).should_not be_nil
      end

      it "should notify a pm" do
        NotifyScheme.create(:pm => @pm, :project => @project,
	  :alert_type => "acc")
	lambda do
	  post :sms_responder, :msisdn => @doctor.mobile, :content => "ACC A"
	end.should change(@pm.to_messages, :count)
      end

      it "should handle ACC properly" do
	lambda do
	  lambda do
	    post :sms_responder, :msisdn => @doctor.mobile, :content => "ACC"
	  end.should change(@doctor.to_messages, :count)
	end.should change(@case.messages, :count)
      end

#      it "should handle the double ACC"
#      it "should handle the double ACC X"
#      it "should handle the triple ACC"
#      it "should handle the triple ACC X"
#      it "should handle the ACC from a doctor who is on another case"

    end

    describe "FIN" do
      before(:each) do
        @doctor = @doctors[rand(@doctors.count)]
	@doctor.update_attributes(:status => "accepted")
        @case = Factory(:case_with_doctor,:vhd => @vhd, :doctor => @doctor )
	@doctor.current_case.should_not be_nil
	@doctor.current_case.should == @case
	@fin_msg = random_fin_msg
      end

      it "should accept a fin sms" do
	lambda do
	  post :sms_responder, :msisdn => @doctor.mobile, :content => @fin_msg
	end.should change(@case.messages, :count)
      end

      it "should resolve the case" do
	post :sms_responder, :msisdn => @doctor.mobile, :content => @fin_msg
	@case.reload.status.should == "resolved"
      end

      it "should pass fin sms to correct vhd" do
	lambda do
	  post :sms_responder, :msisdn => @doctor.mobile, :content => @fin_msg
	end.should change(@vhd.to_messages, :count)
      end

      it "should notify pms" do
        NotifyScheme.create(:pm => @pm, :project => @project,
	  :alert_type => "fin")
	lambda do
	  post :sms_responder, :msisdn => @doctor.mobile, :content => @fin_msg
	end.should change(@pm.to_messages, :count)
      end

#      it "should handle the duplicate req msg"
#      it "should handle a doctor who is not on a case"
#      it "should pass the correct msg content to a vhd"

    end
  end

end
