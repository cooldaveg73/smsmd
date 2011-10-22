class ProjectController < ApplicationController

  def settings
    project = Project.find_by_id(session[:project_id])
    user = User.find_by_id(session[:user_id])
    get_title(project)

    @vhds = project.vhds
    @doctors = project.doctors
    @pms = project.pms
    @users = project.users
    @apms = project.apms
    @project = project
#    @data_type = [ vhds.insert(0, "VHD") , docs.insert(0, "Doctor"), 
#             pms.insert(0, "PM") , users.insert(0, "User"), 
#	     apms.insert(0, "APM") ]

    @is_admin = user.is_admin || false
  end

  def destroy
    get_title
    @title = "Destroy #{person_type}"
    id = params[:id].to_i
    case params[:type].to_s.upcase
      when "VHD"

      when "DOCTOR"

    end
    render 'temp'
 #   redirect_to '/project/settings'
  end

  def edit
    get_title
    @action = "update"
    @submit = "Update"
    id = params[:id].to_i
    case params[:type].to_s.upcase
      when "VHD"
        @vhd = Vhd.find_by_id(id)
	@phcs = @vhd.project.phcs
	vhd_name = [@vhd.first_name, @vhd.last_name].join(' ')
        @title = "Edit VHD #{vhd_name}"
	render 'edit_vhd'
      when "DOCTOR"
        @doctor = Doctor.find_by_id(id)
	doctor_name = [@doctor.first_name, @doctor.last_name].join(' ')
        @title = "Edit Doctor #{doctor_name}"
	render 'edit_doctor'
      when "APM"
    end
  end

  def update
    get_title
    id = params[:id].to_i
    case params[:type].to_s.upcase
      when "VHD"
	@vhd = Vhd.find_by_id(id)
	@vhd.update_attributes(params[:vhd])
	@title = "Edit VHD #{@vhd.name}"
	if @vhd.save
	  @message = "VHD #{@vhd.name} updated!"
	else
	  @message = "VHD NOT updated."
	end
      when "DOCTOR"
        @doctor = Doctor.find_by_id(id)
	@doctor.update_attributes(params[:doctor])
        @title = "Edit Doctor #{@doctor.name}"
	if @doctor.save
	  @message = "Doctor #{@doctor.name} updated!"
	else
	  @message = "Doctor NOT updated."
	end
    end
    render 'show'
  end

  def create
    project = Project.find_by_id(session[:project_id])
    get_title(project)
    case(params[:type].to_s.upcase)
      when "VHD"
	attr = { :status => "vacant", :project => project }
	vhd = Vhd.create( params[:vhd].merge( attr ))
	if vhd.valid?
	  @message = "New VHD #{vhd.name} saved!"
	else
	  @message = "New VHD NOT saved."
	end
	@title = "Add VHD"
      when "DOCTOR"
	attr = { :active => true, :status => "available", :project => project,
	         :last_paged => DateTime.now.new_offset(+5.5/24) }
        doctor = Doctor.create( params[:doctor].merge( attr ))
	if doctor.valid?
	  Shift.create(:start_hour => 0, :start_minute => 0,
	   :start_second => 0, :end_hour => 23,
	   :end_minute => 59, :end_second => 59, :doctor => doctor )
	  @message = "New Doctor #{doctor.name} saved!"
	else
	  @message = "New Doctor NOT saved."
	end
	@title = "Add Doctor"
    end
    render 'show'
  end


  def new
    get_title
    @submit = 'Create'
    @action = 'create'
    person_type = params[:type]
    case params[:type].to_s.upcase
      when "VHD"
        @vhd = Vhd.new
        @title = "Add VHD"
	@phcs = Project.find_by_id(session[:project_id]).phcs
	render 'edit_vhd'
      when "DOCTOR"
        @doctor = Doctor.new
        @title = "Add Doctor"
	render 'edit_doctor'
      when "APM"
    end
  end
  
  def deactivate


  end

  def new_project
    @title = "New Project"
    @subtitle = ""
    render 'edit_project'
  end

  def create_project
    @title = "New Project"
    @subtitle = ""
    name = params[:project][:name]
    users = []
    User.all.each do |user|
      if params[:project][user.id.to_s] == "1"
        users << user
      end
    end
    project = Project.create(:name => name)
    @message = "#{project.name} created with users: "
    users.each do |user|
      @message += "  #{user.name}   "
      project.users << user
    end
    project.save!
    render 'show'
  end

  def doctor_demo
    @title = "Doctor Demo"
    @subtitle = "Please do not use existing doctors for a demo"
    Doctor.reset_doctor_demo
    @req_msg = "Reply ACC A to accept case: HLP Gara Meena 45y 9828390430 High fever and seizures since 4 hours" 
  end

  def page_doctors
    # BUG: doctor_demo information persists
    @req_msg = "Reply ACC A to accept case: HLP Gara Meena 45y 9828390430 High fever and seizures since 4 hours" 
    Doctor.add_doctor_for_demo(params[:doctor_1])
    Doctor.add_doctor_for_demo(params[:doctor_2])
    Doctor.add_doctor_for_demo(params[:doctor_3])
    Doctor.add_doctor_for_demo(params[:doctor_4])
    Doctor.get_demo_doctors.each do |mobile|
      Message.send(mobile, @req_msg)
    end
    render "doctor_demo"
  end

  private

    def get_title( project=Project.find_by_id(session[:project_id]) )
      @title = "Project Settings"
      @subtitle = "#{project.name} Project"
    end

end
