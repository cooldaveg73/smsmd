class SessionsController < ApplicationController
  skip_before_filter :authorize

  def new
    user = User.find_by_id(session[:user_id])
    unless user.nil?
      redirect_to :root
    end
  end

  def create
    if user = User.authenticate(params[:name], params[:password], params[:project])
      session[:user_id] = user.id
      if user.is_admin
        session[:admin] = true
      else
        session[:admin] = false
      end
      redirect_to '/pick_project'
    else
      redirect_to login_url, :alert => "Invalid user/password combination"
    end
  end

  def pick_project
    user = User.find_by_id(session[:user_id])
    if user.projects.count == 1
      session[:project_id] = user.projects.first.id
      if user.new_project == user.project.first
        user.update_attributes(:new_project => nil)
        redirect_to :controller => "new_project", :action => "setup1"
	return
      else
        redirect_to :controller => "cases", :action => "main" 
	return
      end
    else
      @user = user
      @projects = user.projects
    end
  end

  def project
    user = User.find_by_id(session[:user_id])
    session[:project_id] = params[:project_id].to_i
    if user.new_project == Project.find_by_id(params[:project_id].to_i)
      user.update_attributes(:new_project => nil)
      redirect_to :controller => "new_project", :action => "setup1"
      return
    else
      redirect_to :controller => "cases", :action => "main" 
      return
    end
  end

  def destroy
    session[:user_id] = nil
    session[:project_id] = nil
    redirect_to root_url, :notice => "Logged out"
  end

end
