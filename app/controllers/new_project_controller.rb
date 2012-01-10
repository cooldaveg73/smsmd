class NewProjectController < ApplicationController
  require 'net/http'
  skip_before_filter :authorize

  def new
    @promoter = Promoter.new 
  end

  # promoter enters information on form
  def create
    if verify_recaptcha
      # captcha is valid
      @promoter = Promoter.new(params[:@promoter])
      if @promoter.valid?
	@promoter.update_attributes(:key => generate_temp_key(50))
	PromoterMailer.promoter_notification(@promoter).deliver
	redirect_to "/login", :notice => "Please check your email to confirm your email address."
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

  # first link that is sent out to promoter directly after entering info
  def confirm_email
    promoter = Promoter.find_by_id(params[:id])
    begin
      if promoter.key == params[:key]
        User.where("is_admin = ?", true). each do |u| 
	  PromoterMailer.admin_notification(promoter, u).deliver
	end
	# regenerate the key to prevent further use of the link
	@promoter.update_attributes(:key => generate_temp_key(50))
	redirect_to "/login", :notice => "An email was sent to an admin. Please expect a reply shortly."
      else
      redirect_to "/login", :notice => "The key for this promoter is expired or invalid. Please contact Mobilizing Health or retry again later."
      end
    rescue
      redirect_to "/login", :notice => "There was a problem with confirming that promoter."
    end
  end

  # admin grants a new project to the promoter
  def grant
    promoter = Promoter.find_by_id(params[:id])
    if promoter.nil?
      redirect_to "/login", :notice => "Promoter info not found"
      return
    elsif promoter.project
      redirect_to "/login", :notice => "Promoter already has a project."
      return
    end
    project = Project.create(:name => promoter.organization)
    User.where("is_admin = ?", true).each { |u| u.projects << project }
    temp_pass = generate_temp_key
    u = User.create(:name => promoter.username, :password => temp_pass, 
      :is_admin => false, :projects => [project], :new_project => project)
    promoter.update_attributes(:project => project)
    PromoterMailer.registration_confirmation(promoter, u, temp_pass).deliver
    redirect_to "/login", :notice => "Grant action fulfilled for #{project.name} Project. An email has been sent to the promoter."
  end

  def setup1
  end

end
