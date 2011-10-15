require 'spec_helper'

describe "cron" do

  def run_cron
    load Rails.root.to_s + "/script/cron.rb"
  end

  it "should not break" do
    run_cron
  end

  it "should close accepted cases with no answer" do
    one_fifty_mins_ago = 150.minutes.ago.utc.to_datetime
    kase = Factory(:newly_opened_case, :time_opened => one_fifty_mins_ago, 
                    :time_accepted => one_fifty_mins_ago + 5.minutes,
		    :status => "accepted", :doctor => Factory(:doctor) )
    run_cron
    kase.reload.status.should == "closed"
  end

  it "should make doctors available" do
    doctor = Factory(:doctor, :last_paged => 60.minutes.ago.utc.to_datetime,
                      :status => "opened" )
    run_cron
    doctor.reload.status.should == "available"
  end

  it "should close opened cases with no response" do
    one_fifty_mins_ago = 150.minutes.ago.utc.to_datetime
    kase = Factory(:newly_opened_case, :time_opened => one_fifty_mins_ago)
    run_cron
    kase.reload.status.should == "closed"
  end

  it "should provide an acc reminder" do
    project = Factory(:project)
    doctor = Factory(:doctor, :project => project, :status => "accepted",
                     :last_paged => 10.minutes.ago.utc.to_datetime )
    vhd = Factory(:vhd, :project => project)
    kase = Factory(:case_with_doctor, :vhd => vhd, :doctor => doctor,
                   :time_accepted => 10.minutes.ago.utc.to_datetime )
    doctor.update_attributes( :status => "accepted" )
    run_cron
    query_args = [ "msg LIKE ?", kase.acc_reminder ]
    doctor.to_messages.where(query_args).count.should == 1
  end

  it "should alert pms" do
    project = Factory(:project, :name => "Udaipur" )
    pm = Factory(:pm, :first_name => "Sheela", :projects => [project])
    NotifyScheme.create(:pm => pm, :project => project, :alert_type => "alert")
    vhd = Factory(:vhd, :project => project)
    kase = Factory(:newly_opened_case, :vhd => vhd, 
      :time_opened => 50.minutes.ago.utc.to_datetime)
    kase.status.should == "opened"
    run_cron
    query_args = [ "msg LIKE ?", kase.alert_for_pm ]
    pm.to_messages.where(query_args).count.should == 1
  end

  it "should page doctors" do
    project = Factory(:project, :name => "Udaipur" )
    10.times { Factory(:doctor, :project => project, :status => "available") }
    vhd = Factory(:vhd, :project => project )
    kase = Factory( :newly_opened_case, :vhd => vhd, 
                    :time_opened => 25.minutes.ago.utc.to_datetime,
		    :last_message_time => 15.minutes.ago.utc.to_datetime )
    kase.doctors_paged.count.should == 0
    run_cron
    kase.doctors_paged.count.should > 0
  end

  it "should page doctors who have not already been paged"

end
