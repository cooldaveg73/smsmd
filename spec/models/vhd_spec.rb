# == Schema Information
#
# Table name: vhds
#
#  id         :integer(4)      not null, primary key
#  first_name :string(20)
#  last_name  :string(20)
#  mobile     :string(20)
#  status     :string(10)
#  notes      :string(1024)
#  village_id :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer(4)
#  phc_id     :integer(4)
#  is_patient :boolean(1)      default(FALSE)
#  doctor_id  :integer(4)
#  department :string(24)
#

require 'spec_helper'

describe Vhd do

  before(:each) do
    @vhd = Factory(:vhd)
  end

  describe "model specs" do

    it "should create a vhd given valid attributes" do
      Vhd.create(@vhd.attributes).class.should == Vhd
    end

    it "should restrict destroy for a vhd with cases" do
      10.times { Factory(:case, :vhd => @vhd, :status => "closed") }
      lambda { @vhd.destroy }.should raise_error(DELETE_RESTRICTED)
    end

    it "should restrict destroy for a vhd with messages" do
      10.times do
        Factory(:from_vhd_message, :from_person => @vhd)
	Factory(:to_vhd_message, :to_person => @vhd)
      end
      lambda { @vhd.destroy }.should raise_error(DELETE_RESTRICTED)
    end
  end

  describe "methods" do

    it "should produce unique names" do
      project = Factory(:project)
      first_name = "Pooja"
      vhd_1 = Factory(:vhd, :first_name => first_name, :project => project)
      vhd_1.name.should == first_name
      vhd_2 = Factory(:vhd, :first_name => first_name, :project => project)
      vhd_2.name.should == [ vhd_2.first_name, vhd_2.last_name ].join(" ")
    end

    it "should have no unfinished cases at start" do
      @vhd.unfinished_cases.should == []
    end

    it "should have unfinished cases" do
      cases = []
      10.times do
	cases << Factory(:case, :vhd => @vhd, :status => "accepted")
	cases << Factory(:case, :vhd => @vhd, :status => "scribed")
	cases << Factory(:case, :vhd => @vhd, :status => "opened")
      end
    end
  end
end

