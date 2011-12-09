class FollowupController < ApplicationController

  def options
    @notice = params['notice']
    @title = "Followup Options"
  end

  def results
    @title = "Followup Search Results"
    project = get_project_and_set_subtitle
    authorize_project(project)
    per_page_count = 15
    pages = get_pages( 0, per_page_count, project.cases.count )
   
    if !(params['caseform']== nil) && !(Case.find(:all, :conditions => { :id => params['caseform']['id'],:followed_up => nil, :status => 'resolved'}).size == 0)
	@cases = [Case.find_by_id(params['caseform']['id'])]
    elsif (params['start_date'] == nil)
	redirect_to :action => 'options', :notice => "No Results Found"
    else
	sp = params['start_date']
	start_date = DateTime.civil(sp['(1i)'].to_i, sp['(2i)'].to_i, sp['(3i)'].to_i, sp['(4i)'].to_i, 0, 0, 0)
	ep = params['end_date']
	end_date = DateTime.civil(ep['(1i)'].to_i, ep['(2i)'].to_i, ep['(3i)'].to_i, ep['(4i)'].to_i, 0, 0, 0)
        cases = Case.find(:all, :conditions => { :time_closed_or_resolved => start_date..end_date, :status => 'resolved', :followed_up => nil})
	if(cases.size == 0)
		redirect_to :action => 'options', :notice => "No Results Found"
	end	
	if(cases.size > per_page_count)
		cases = cases.shuffle
		cases = cases.slice(0..per_page_count -1)
	end
	@cases = cases
        
    end
  end

  def form
    @timezone = +5.5
    @title = "Followup Form"
    @kase = Case.find_by_id(params[:id].to_i)
    @patient = Patient.find_by_id(@kase.patient_id)
    @followup = Followup.new
     if params[:edit] == '1'
	@patient.update_attributes(:first_name => params[:patient][:first_name].to_s)
	@patient.update_attributes(:last_name => params[:patient][:last_name].to_s)
	@patient.update_attributes(:mobile => params[:patient][:mobile].to_s)
	@patient.update_attributes(:age => params[:patient][:age].to_i)
    end
  end

  def success
    if @followup = Followup.create(params[:followup])
	@followup.update_attributes(:case_id => params[:id].to_i)
	symptom = Array.new
	symptom_primitives = Array["Fever", "Cough", "Cold", "Diarrhea", "Stomach Ache", "Head Ache", "Rash"]
	(1..7).each do |i|
		s = 's' + i.to_s
		if params[s].to_i== 1
	    		symptom.push(symptom_primitives[i-1])
		end
	end
	(8..10).each do |i|
		s = 's' + i.to_s
		if params[s].to_s != ""
	    		symptom.push(params[s].to_s)
		end
	end
	action_primitives = Array["Tablets", "Syrup", "Injections", "See PHC", "Hospital", "At Home", "Quack Doctor", "Medical Dispensary"]
        patient = Array.new
	doctor = Array.new
	(0..7).each do |i|
		s = 's2' + i.to_s
		if params[s].to_i== 1
	    		patient.push(action_primitives[i])
		end
	end
        if params[:s28].to_s != ""
	    patient.push(params[:s48].to_s)
	end
	(0..7).each do |i|
		s = 's3' + i.to_s
		if params[s].to_i== 1
	    		doctor.push(action_primitives[i])
		end
	end
        if params[:s38].to_s != ""
	    doctor.push(params[:s48].to_s)
	end
        @followup.update_attributes(:symptoms => symptom)
	@followup.update_attributes(:patient_did => patient)
	@followup.update_attributes(:doctor_recommended => doctor)
        @title = "Followup Success"
        @kase = Case.find_by_id(params[:id].to_i)
        @kase.update_attributes(:followed_up => true)
    else
        @title = "Followup Unsuccessful"
    end
  end

  def failure
    @title = "Followup Unsuccessful"
  end

end
