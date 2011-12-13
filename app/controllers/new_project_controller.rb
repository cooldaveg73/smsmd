class NewProjectController < ApplicationController
  skip_before_filter :authorize

  def new
    @promoter = Promoter.new 
  end

  def create
    if verify_recaptcha
      redirect_to "/login"
    else
      flash[:error] = "There was an error with the recaptcha code below. Please re-enter the code and click submit." 
      render :action => 'new'
    end  
  end

end
