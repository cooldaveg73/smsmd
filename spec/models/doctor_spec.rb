# == Schema Information
#
# Table name: doctors
#
#  id               :integer(4)      not null, primary key
#  first_name       :string(20)
#  last_name        :string(20)
#  mobile           :string(20)
#  last_paged       :datetime
#  specialty        :string(20)
#  hospital_id      :integer(4)
#  active           :boolean(1)
#  user_id          :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#  project_id       :integer(4)
#  points           :integer(4)      default(0)
#  points_timestamp :datetime
#  status           :string(24)
#

require 'spec_helper'

describe Doctor do

  before(:each) do
    @project = Factory(:project)
    @doctor = Factory(:doctor, :project => @project)
  end

  describe "model specs" do

    it "should create a doctor given valid attributes" do
      Doctor.create(@doctor.attributes).class.should == Doctor
    end

    it "should restrict destroy when a doctor has cases" do
      10.times { Factory(:case_with_doctor, :doctor => @doctor) }
      lambda { @doctor.destroy }.should raise_error(DELETE_RESTRICTED)
    end

    it "should nullify vhds who have a deleted doctor" do
      vhds = []
      10.times { vhds << Factory(:vhd, :doctor => @doctor) }
      @doctor.destroy
      vhds.each { |v| v.reload.doctor.should be_nil }
    end

    it "should destroy shifts for a deleted doctor" do
      shift = Factory(:shift, :doctor => @doctor)
      @doctor.destroy
      lambda { shift.reload }.should raise_error(RECORD_NOT_FOUND)
    end

    it "should restrict destroy for a doctor with messages" do
      10.times do 
	Factory(:to_doctor_message, :to_person => @doctor)
	Factory(:from_doctor_message, :from_person => @doctor)
      end
      lambda { @doctor.destroy }.should raise_error(DELETE_RESTRICTED)
    end

    it "should require a first name" do
      invalid_attr = Factory.attributes_for(:doctor).merge(:first_name => "")
      no_name_doctor = Doctor.new( invalid_attr )
      no_name_doctor.should_not be_valid 
    end

    it "should require a mobile" do
      invalid_attr = Factory.attributes_for(:doctor).merge(:mobile => "")
      no_name_doctor = Doctor.new( invalid_attr )
      no_name_doctor.should_not be_valid 
    end
  end

  describe "methods" do

    it "should produce unique names" do
      last_name = "Verma"
      doctor_1 = Factory(:doctor, :last_name => last_name, :project => @project)
      doctor_1.name.should == last_name
      first_name = doctor_1.first_name.first.next.upcase + doctor_1.first_name
      doctor_2 = Factory(:doctor, :first_name => first_name.humanize, 
                         :last_name => last_name, :project => @project )
      doctor_2.name.should == first_name.first + " " + last_name
      doctor_3 = Factory(:doctor, :first_name => first_name.humanize,
                         :last_name => last_name, :project => @project )
      doctor_3.name.should == [ first_name.humanize, last_name ].join(" ")
    end


    it "should have a letter order" do
      letter = "A"
      15.times do
	@doctor.next_letter.should == letter
	page_doctor_and_return_case(@doctor)
	letter = letter.next
      end
    end

    it "should return proper cases for proper letter" do
      letter = "A"
      15.times do
        kase = page_doctor_and_return_case(@doctor)
	@doctor.case_on_letter(letter).should_not be_nil
	@doctor.case_on_letter(letter).should == kase
	letter = letter.next
      end
    end

    it "should return nil if no letter matches" do
      page_doctor_and_return_case(@doctor)
      @doctor.case_on_letter("A").should_not be_nil
      letter = "B"
      23.times do 
	@doctor.case_on_letter(letter).should be_nil
	letter = letter.next
      end
      10.times { page_doctor_and_return_case(@doctor) }
      letter = "M"
      13.times do 
	@doctor.case_on_letter(letter).should be_nil
	letter = letter.next
      end
    end

    it "should give a new set of letters every day" do
      yesterday = DateTime.now.new_offset(+5.5/24) - 1.day
      params = { :time_opened => yesterday.beginning_of_day.utc.to_datetime }
      (1..5).each { page_doctor_and_return_case(@doctor, params) }
      kase = page_doctor_and_return_case(@doctor)
      @doctor.case_on_letter("A").should == kase
    end

    it "should give doctors different letters" do
      5.times do
	doctor = Factory(:doctor)
	kase = page_doctor_and_return_case(doctor)
	doctor.case_on_letter("A").should == kase
      end
    end

    it "should return unclosed cases when a doctor has old cases" do
      cases = []
      10.times do 
	cases << Factory(:case, :status => "accepted", :doctor => @doctor)
	cases << Factory(:case, :status => "scribed", :doctor => @doctor)
      end
      cases = cases.sort_by { |kase| kase.id }
      opened_cases = @doctor.unclosed_cases.to_a.sort_by { |kase| kase.id }
      cases.should == opened_cases
    end

    it "should not return closed cases when requesting old cases" do
      10.times do 
	Factory(:case, :status => "resolved", :doctor => @doctor)
	Factory(:case, :status => "opened", :doctor => @doctor)
	Factory(:case, :status => "closed", :doctor => @doctor)
      end
      @doctor.unclosed_cases.should == []
    end

    it "should be consistent when find a letter with a case and vice versa" do
      letter = "A"
      (1..15).each do |num|
	kase = page_doctor_and_return_case(@doctor)
	if num.even?
	  temp_letter = @doctor.letter_on_case(kase)
	  temp_letter.should_not be_nil
	  @doctor.case_on_letter(temp_letter).should == kase
	else
	  temp_case = @doctor.case_on_letter(letter)
	  temp_case.should_not be_nil
	  @doctor.letter_on_case(temp_case).should == letter
	end
	letter = letter.next
      end
    end

    it "should return acc_options when there are options" do
      10.times { page_doctor_and_return_case(@doctor) }
      @doctor.acc_options.should_not be_nil
    end

    it "should return nil when there are no options" do
      10.times { page_doctor_and_return_case(@doctor).close }
      @doctor.acc_options.should be_nil
    end

    it "should return the current_case" do
      case_1 = Factory(:case_with_doctor, :doctor => @doctor)
      case_1.close
      case_2 = Factory(:case_with_doctor, :doctor => @doctor)
      @doctor.current_case.should == case_2
    end
  end
end
