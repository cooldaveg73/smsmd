class ProjectController < ApplicationController

  # top level page for this controller; a view that allows the user to call into other parts of this controller
  def settings
    project = Project.find_by_id(session[:project_id])
    user = User.find_by_id(session[:user_id])
    get_title(project)

    @message = params[:message] || ""
    @vhds = project.vhds.where("status != ?", "deleted")
    @doctors = project.doctors("status != ?", "deleted")
    @pms = project.pms
    @users = project.users
    @apms = project.apms
    @project = project
    @is_admin = user.is_admin || false
  end

  # deletes a doctor or VHD. Deleting here really just means that the project
  # manager will no longer see them. Their information persists in the system
  # for data collection and so that viewing old data through the application
  # maintains that information.
  def destroy
    get_title
    id = params[:id].to_i
    case params[:type].to_s.upcase
      when "VHD"
	    @vhd = Vhd.find_by_id(id)
	    @vhd.update_attributes(:status => "deleted", :project => nil)
	    if @vhd.save
	      @message = "VHD #{@vhd.full_name} deleted!"
	    else
	      @message = "VHD not deleted."
	    end
        if @vhd.is_patient_buyer
          redirect_to :action => :manage_patient_vhds, :message => @message
          return
        end
      when "DOCTOR"
        @doctor = Doctor.find_by_id(id)
        @doctor.update_attributes(:status => "deleted", :project => nil)
	    if @doctor.save
	      @message = "Doctor #{@doctor.full_name} deleted!"
	    else
	      @message = "Doctor not deleted."
	    end
    end
    redirect_to :action => :settings, :message => @message
  end

  # sets a user's status to "active"; this affects the behavior in other parts
  # of the application
  def activate
    get_title
    id = params[:id].to_i
    case params[:type].to_s.upcase
      when "VHD"
	    @vhd = Vhd.find_by_id(id)
	    @vhd.update_attributes(:status => "vacant")
	    if @vhd.save
	      @message = "VHD #{@vhd.full_name} activated!"
	    else
	      @message = "VHD not activated."
	    end
        if @vhd.is_patient_buyer
          redirect_to :action => :manage_patient_vhds, :message => @message
          return
        end
      when "DOCTOR"
        @doctor = Doctor.find_by_id(id)
        @doctor.update_attributes(:status => "available")
	    if @doctor.save
	      @message = "Doctor #{@doctor.full_name} activated!"
	    else
	      @message = "Doctor not activated."
	    end
      when "PM"
        @pm = Pm.find_by_id(id)
        @pm.update_attributes(:active => true)
        if @pm.save
          @message = "PM #{@pm.full_name} activated!"
        else
          @message = "PM not activated"
        end
    end
    redirect_to :action => :settings, :message => @message
  end

  # a user can be deactivated for a period of time by the project manager. the
  # project manager might do this if a doctor is on vacation or a VHD is
  # sending in inappropriate messages. The project manager can reactivate them
  # at any time by clicking activate. The difference between deactivate and
  # destroy is that the project manager can still look at the user.
  def deactivate
    get_title
    id = params[:id].to_i
    case params[:type].to_s.upcase
      when "VHD"
	    @vhd = Vhd.find_by_id(id)
	    @vhd.update_attributes(:status => "deactivated")
	    if @vhd.save
	      @message = "VHD #{@vhd.full_name} deactivated!"
	    else
	      @message = "VHD not deactivated."
	    end
        if @vhd.is_patient_buyer
          redirect_to :action => :manage_patient_vhds, :message => @message
          return
        end
      when "DOCTOR"
        @doctor = Doctor.find_by_id(id)
        @doctor.update_attributes(:status => "deactivated")
	    if @doctor.save
	      @message = "Doctor #{@doctor.full_name} deactivated!"
	    else
	      @message = "Doctor not deactivated."
	    end
      when "PM"
        @pm = Pm.find_by_id(id)
        @pm.update_attributes(:active => false)
        if @pm.save
          @message = "PM #{@pm.full_name} deactivated!"
        else
          @message = "PM not deactivated"
        end
    end
    redirect_to :action => :settings, :message => @message
  end

  def edit
    project = get_project_and_set_subtitle
    @action = "update"
    @submit = "Update"
    id = params[:id].to_i
    case params[:type].to_s.upcase
      when "VHD"
        @vhd = Vhd.find_by_id(id)
        @is_patient_buyer = @vhd.is_patient_buyer && project.has_patient_buyers
    	@phcs = @vhd.project.phcs
        @title = "Edit VHD #{@vhd.full_name}"
    	render 'edit_vhd'
      when "DOCTOR"
        @doctor = Doctor.find_by_id(id)
        @title = "Edit Doctor #{@doctor.full_name}"
    	render 'edit_doctor'
    end
  end

  def update
    get_title
    id = params[:id].to_i
    case params[:type].to_s.upcase
      when "VHD"
	    @vhd = Vhd.find_by_id(id)
	    @vhd.update_attributes(params[:vhd])
	    @title = "Edit VHD #{@vhd.full_name}"
	    if @vhd.save
	      @message = "VHD #{@vhd.full_name} updated!"
	    else
	      @message = "VHD NOT updated."
	    end
        if @vhd.is_patient_buyer
          redirect_to :action => :manage_patient_vhds, :message => @message
          return
        end
      when "DOCTOR"
        @doctor = Doctor.find_by_id(id)
        @doctor.update_attributes(params[:doctor])
        @title = "Edit Doctor #{@doctor.full_name}"
	    if @doctor.save
	      @message = "Doctor #{@doctor.full_name} updated!"
	    else
	      @message = "Doctor NOT updated."
	    end
      else
        @title = "Nothing Edited"
        @message = "You did not edit anything"
    end
    redirect_to :action => :settings, :message => @message
  end

  def create
    project = Project.find_by_id(session[:project_id])
    get_title(project)
    case(params[:type].to_s.upcase)
      when "VHD"
        attr = { :status => "vacant", :project => project }
        vhd = Vhd.create(params[:vhd].merge(attr))
        if vhd.valid?
          @message = "New VHD #{vhd.full_name} saved!"
        else
          @message = "New VHD NOT saved."
        end
        if vhd.is_patient_buyer
          redirect_to :action => :manage_patient_vhds, :message => @message
          return
        end
      when "DOCTOR"
        attr = { :active => true, :status => "available", :project => project,
            :last_paged => DateTime.now.new_offset(+5.5/24) }
        doctor = Doctor.create( params[:doctor].merge( attr ))
        if doctor.valid?
          Shift.create(:start_hour => 0, :start_minute => 0,
           :start_second => 0, :end_hour => 23,
           :end_minute => 59, :end_second => 59, :doctor => doctor )
          @message = "New Doctor #{doctor.full_name} saved!"
        else
	      @message = "New Doctor NOT saved."
	    end
    end
    redirect_to :action => :settings, :message => @message
  end

  def new
    get_title
    project = get_project_and_set_subtitle
    @submit = 'Create'
    @action = 'create'
    person_type = params[:type]
    case params[:type].to_s.upcase
      when "VHD"
        if params[:patient_buyer] == "true" && project.has_patient_buyers
          @vhd = Vhd.new(:buyer_count => 10, :is_patient => true, :is_patient_buyer => true)
          @is_patient_buyer = true
          @title = "Add Patient Buyer VHD"
        else
          @vhd = Vhd.new
          @is_patient_buyer = false
          @title = "Add VHD"
        end
	    @phcs = project.phcs
	    render 'edit_vhd'
      when "DOCTOR"
        @doctor = Doctor.new
        @title = "Add Doctor"
	    render 'edit_doctor'
      when "APM"
    end
  end

  def manage_patient_vhds
    project = get_project_and_set_subtitle
    @message = params[:message] || ""
    @title = "Manage Patient VHDs"
    @patient_buyers = project.vhds.where("is_patient_buyer = ? AND status != ?", true, "deleted")
    user = User.find_by_id(session[:user_id])
    @is_admin = user.is_admin || false
  end

  private

    def get_title( project=Project.find_by_id(session[:project_id]) )
      @title = "Project Settings"
      @subtitle = "#{project.name} Project"
    end

end
