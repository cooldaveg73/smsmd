require 'spec_helper'

describe ReportingController do

  it "should respond to a request" do
    get :new
    response.should be_success
  end


end
