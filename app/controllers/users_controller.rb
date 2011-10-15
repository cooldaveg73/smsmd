class UsersController < ApplicationController
  # before_filter :check_if_admin
  # GET /users
  # GET /users.xml

  def index
    get_title
    user = User.find_by_id(session[:user_id])
    if user.is_admin
      @users = User.order(:name)
    else
      @users = [ user ]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    get_title
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    get_title
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    get_title
    @user = User.find(params[:id])
    @title = "Edit User \"#{@user.name}\""
  end

  # POST /users
  # POST /users.xml
  def create
    get_title
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(users_url, :notice => "User #{@user.name} was successfully created.") }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    get_title
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(users_url, :notice => "User #{@user.name} was successfully created.") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    get_title
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
    def check_if_admin
      unless session[:admin]
        redirect_to :root
      end
    end

    def get_title
      project = Project.find_by_id(session[:project_id])
      @title = "Manage Users"
      @subtitle = "#{project.name} Project"
    end
end
