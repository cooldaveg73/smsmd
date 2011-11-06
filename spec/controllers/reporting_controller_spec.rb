require 'spec_helper'

describe ReportingController do

  it "should respond to a request" do
    test_sign_in
    get :new
    response.should be_success
  end


end
