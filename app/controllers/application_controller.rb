class ApplicationController < ActionController::Base
  include ApplicationHelper
  include SessionsHelper
  before_filter :authorize
  protect_from_forgery

  def authorize_project(project)
    user = User.find_by_id(session[:user_id])
    redirect_to login_url and return if user.nil?
    unless user.projects.include?(project)
      notice = "You cannot view data from that project"
      redirect_to "/logout", :notice => notice
      return false
    end
    return true
  end
  
  protected
    
    def authorize
      user = User.find_by_id(session[:user_id])
      redirect_to login_url and return if user.nil?
      project = Project.find_by_id(session[:project_id])
      unless user.projects.include?(project)
	notice = "You cannot view data from that project"
	redirect_to "/logout", :notice => notice
	return
      end
    end

end
