# == Schema Information
#
# Table name: projects
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  has_reqs              :boolean(1)      default(FALSE)
#  has_hlps              :boolean(1)      default(FALSE)
#  include_doctor_name   :boolean(1)      default(TRUE)
#  include_doctor_mobile :boolean(1)      default(TRUE)
#  mobile                :string(24)      default("9223173098")
#  unregistered_msg      :string(1024)    default("You have not been registered into the system. Please contact your hospital or project manager for registration.")
#  close_msg             :string(1024)    default("Ye Case, Patient |PATIENT| ki liye, bund hogaya. Apko kisi karan is case ka jawab nahi mile aur abhi bhi jewab ke jerurat he tho dubara REQ ka sms kare.")
#  req_format_msg        :string(1024)    default("Sorry, wrong format. Please re-send in this way: REQ (patient good name) (patient surname) (patient age (40y, A, C, I, E, P)) (patient mobile) (patient symptoms)")
#  time_zone             :decimal(3, 1)
#  location              :string(24)
#  has_patient_buyers    :boolean(1)
#  has_doctor_game       :boolean(1)
#  hlp_format_msg        :string(1024)
#  has_ans               :boolean(1)
#

require 'spec_helper'

describe Project do

  before(:each) do
    @project = Factory(:project)
  end

  describe "model specs" do

    it "should create a project given valid attributes" do
      Project.create(@project.attributes).class.should == Project
    end

    it "should nullify all doctors after destroy" do
      doctors = []
      10.times { doctors << Factory(:doctor, :project => @project) }
      @project.delete
      doctors.each { |doctor| doctor.reload.project.should be_nil }
    end

    it "should nullify all vhds after destroy" do
      vhds = []
      10.times { vhds << Factory(:vhd, :project => @project) }
      @project.delete
      vhds.each { |vhd| vhd.reload.project.should be_nil }
    end

    it "should nullify all patients after destroy" do
      patients = []
      10.times { patients << Factory(:patient, :project => @project) }
      @project.delete
      patients.each { |patient| patient.reload.project.should be_nil }
    end

    it "should not save a project without a name" do
      invalid_attr = @project.attributes.merge(:name => "")
      no_name_project = Project.new(invalid_attr)
      no_name_project.should_not be_valid
    end
  end

  describe "methods" do

    it "should return a nil doctor if there are no doctors" do
      kase = Factory(:newly_opened_case)
      @project.get_doctors_to_page(kase).should == []
    end

    it "should use the scheme with priority 1 first" do
      doctor = Factory(:doctor, :project => @project)
      10.times { Factory(:doctor, :project => @project) }
      kase = Factory(:newly_opened_case)
      PagingScheme.create(:priority => 1, :project => @project,
        :doctor => doctor)
      @project.get_doctors_to_page(kase).should == [doctor]
    end

    it "should return an available doctor" do
      10.times do 
        Factory(:doctor, :status => "available", :project => @project)
      end
      doctor = @project.get_available_doctor
      doctor.class.should == Doctor
      doctor.status.should == "available"
      last_paged = Time.at(0).to_datetime
      20.times do
	doctor = @project.get_available_doctor
	break if doctor.blank?
	doctor.class.should == Doctor
	doctor.last_paged.should >= last_paged
	doctor.status.should == "available"
	doctor.project.should == @project
	doctor.update_attributes(:status => "opened")
	last_paged = doctor.last_paged
      end
    end

    it "should return a nil doctor when there are no doctors to page"

  end
end
