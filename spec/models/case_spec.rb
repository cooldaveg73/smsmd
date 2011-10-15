# == Schema Information
#
# Table name: cases
#
#  id                      :integer(4)      not null, primary key
#  status                  :string(10)
#  followed_up             :boolean(1)
#  fake                    :boolean(1)
#  success                 :boolean(1)
#  alerted                 :boolean(1)
#  doctor_id               :integer(4)
#  vhd_id                  :integer(4)
#  patient_id              :integer(4)
#  time_opened             :datetime
#  time_accepted           :datetime
#  time_closed_or_resolved :datetime
#  last_message_time       :datetime
#  created_at              :datetime
#  updated_at              :datetime
#  project_id              :integer(4)
#  tag                     :integer(4)
#

require 'spec_helper'

describe Case do

  before(:each) do
    @case = Factory(:newly_opened_case)
  end

  describe "model specs" do
    it "should create a case given valid attributes" do
      Case.create(@case.attributes).class.should == Case
    end

    it "should restrict destroy on a case that has messages" do
      lambda { @case.destroy }.should raise_error(DELETE_RESTRICTED)
    end
  end

  describe "methods" do
    it "should create a new case for a vhd" do
      lambda do
	Case.new_case_from_vhd(Factory(:vhd), Factory(:patient))
      end.should change(Case, :count)
    end

    it "should return no doctors when no doctors have been paged" do
      @case.doctors_paged.should == []
    end

    it "should return doctors when doctors have been paged" do
      (0..2).each do |num|
        time_sent = @case.time_opened + (num*10).minutes
	Factory(:page_message, :case => @case, :time_sent => time_sent)
      end
      @case.doctors_paged.count.should == 3
    end

    it "should handle a case with an acc" do
      @case = Factory(:case_with_doctor)
      doctor = @case.doctor
      @case.update_attributes(:status => "opened", :doctor => nil)
      project = @case.project
      pm = Factory(:pm, :projects => [project])
      NotifyScheme.create(:alert_type => "acc", :pm => pm, :project => project)
      @case.handle_case_with_acc(doctor)
      @case.reload
      @case.doctor.should == doctor
      @case.status.should == "accepted"
      @case.messages.where("to_person_type = ?", "Pm").should_not == []
    end

    it "should return something for acc methods" do
      @case = Factory(:case_with_doctor)
      @case.acc_for_doctor.should_not be_nil
      @case.acc_for_vhd.should_not be_nil
      @case.acc_for_pm.should_not be_nil
      @case.acc_for_patient.should_not be_nil
    end

    it "should return a req notification" do
      @case.req_for_pm.should_not be_nil
    end

    it "should return fin methods" do
      @case = Factory(:finished_case)
      @case.fin_for_vhd.should_not be_nil
      @case.fin_for_pm.should_not be_nil
    end

    it "should reopen" do
      @case.reopen
      @case.reload.status.should == "opened"
    end

    it "should generate a complaint" do
      @case.project.update_attributes(:has_reqs => true)
      @case.complaint.should_not be_blank
    end
      
  end
end


