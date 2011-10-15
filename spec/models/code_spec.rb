# == Schema Information
#
# Table name: codes
#
#  id           :integer(4)      not null, primary key
#  abbreviation :string(255)
#  expansion    :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe Code do

  it "should return a message for fin" do
    fin = "FIN pcm 1tab 2bds and get plenty of rest; go to hospital"
    message = Code.expand(fin, true)
    message.length.should > 10
  end

  it "should return a message for anything else" do
    other = "pcm 1tab 2bds and get plenty of rest; go to hospital"
    message = Code.expand(other)
    message.length.should > 10
  end

  it "should expand pcm" do
    Code.create( :abbreviation => "PCM", :expansion => "Paracetamol")
    Code.expand("pcm").should == "Paracetamol"
    Code.expand("fin pcm", true).should == "Paracetamol"
  end


end
