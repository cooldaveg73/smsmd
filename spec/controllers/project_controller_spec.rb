require 'spec_helper'

describe ProjectController do

  it "should respond to a request" do
    test_sign_in
    get :settings
    response.should be_success
  end

end

