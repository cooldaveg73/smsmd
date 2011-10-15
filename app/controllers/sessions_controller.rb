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
      redirect_to :controller => 'cases', :action => 'main' 
    else
      @projects = user.projects
    end
  end

  def project
    session[:project_id] = params[:project_id].to_i
    redirect_to :controller => 'cases', :action => 'main' 
  end

  def destroy
    session[:user_id] = nil
    session[:project_id] = nil
    redirect_to root_url, :notice => "Logged out"
  end

end
