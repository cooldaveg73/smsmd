class NewProjectController < ApplicationController
  require 'net/http'
  skip_before_filter :authorize

  def new
    @promoter = Promoter.new 
  end

  def create
    if verify_recaptcha
      # captcha is valid
      promoter = Promoter.new(params[:@promoter])
      if promoter.save
        if PromoterMailer.promoter_notification(promoter).deliver
        PromoterMailer.admin_notification(promoter).deliver
        redirect_to "/login", :notice => "An email was sent to an administrator to confirm. Expect a reply shortly."
	end
      else
        flash[:error] = "There was an error saving the promoter information. Please double check and try again."
        render :action => 'new'
      end
    else
      # captcha is invalid
      flash[:error] = "There was an error with the recaptcha code below. Please re-enter the code and click submit." 
      render :action => 'new'
    end  
  end

  def grant
    promoter = Promoter.find_by_id(params[:id])
    if promoter.nil?
      redirect_to "/login", :notice => "Promoter info not found"
      return
    end
    project = Project.create(:name => promoter.organization)
    random_chars = ('A'..'Z').to_a + ('a'..'z').to_a + (1..9).to_a.map { |i| i.to_s }
    temp_pass = ""
    (rand(5) + 6).times { |i| temp_pass << random_chars[rand(random_chars.count)] }
    User.create(:name => promoter.username, :password => temp_pass, 
      :is_admin => false, :projects => [project])
    redirect_to "/login", :notice => "Grant action fulfilled."
  end

end
