class MessagesController < ApplicationController
  include MessagesHelper

  skip_before_filter :authorize,
    :only => [:sms_responder, :delivery_status, :send_sms]

  def messages
    project = get_project_and_set_subtitle
    current_page = params[:page].to_i
    if params[:person_type].match(/doctor/i)
      person = Doctor.find_by_id(params[:person_id])
    elsif params[:person_type].match(/vhd/i)
      person = Vhd.find_by_id(params[:person_id])
    elsif params[:person_type].match(/pm/i)
      person = Pm.find_by_id(params[:person_id])
    end
    if person.nil?
      redirect_to :root
      return
    end
    if person.respond_to?("project")
      authorize_project(person.project)
      # TODO: needs to return here otherwise makes a bug
    elsif person.respond_to?("projects")
      unless person.projects.include?(project)
        redirect_to :root
        return
      end
    else
      redirect_to :root
      return
    end
    per_page_count = 100
    query = "((from_person_id = :id AND from_person_type = :class) OR 
      (to_person_id = :id AND to_person_type = :class)) 
      AND project_id = :project_id"
    data = { :id => person.id, :class => person.class.to_s, 
      :project_id => project.id }
    begin_index = current_page * per_page_count
    @messages = Message.where(query, data).order("id DESC").offset(begin_index).limit(per_page_count)
    total = Message.where(query, data).count
    @prev_page, @next_page = get_pages(current_page, per_page_count, total)
    @timezone = +5.5
    @title = "Messages: #{person.full_name}"
    @mobile = person.mobile
    @person = person
    render :layout => "sortable_table"
  end

  def send_sms
    dest = params[:dest] || ""
    message = params[:message] || ""
    project = get_project_and_set_subtitle
    message = message.strip()[0...160]
    sending_status = "Message could not be delivered to smsgupshup."
    sending_success = false
    # /d{10} is a ten-digit number
    if dest.match(/\d{10}/)
      sending_status = "Message successfully delivered."
      sending_success = true
      send_info = { :msg => message, :project => project }
      vhd = Vhd.find_by_mobile(dest)
      unless vhd.nil?
        if Message.send_to_person(vhd, send_info).external_id.nil?
	  sending_status = "Message could not be delivered to Gateway."
	  sending_success = false
	end
      else
	doctor = Doctor.find_by_mobile(dest)
	unless doctor.nil?
	  if Message.send_to_person(doctor, send_info).external_id.nil?
	    sending_status = "Message could not be delivered to Gateway."
	    sending_success = false
	  end
	end
      end
    end
    render :json => {:result => sending_status, :success => sending_success}
  end

  def sms_responder
    source = params[:msisdn] || ""
    dest = params[:phonecode] || ""
    text = params[:content] || ""
    location = params[:location] || ""
    if source[0...2] == "91" && source.length > 10
      source = source[2...source.length]
    end
    if Demoer.find_by_mobile(source)
      redirect_to URI.encode("/handle_demoer?mobile=#{source}&text=#{text}")
      return
    end
    @save_info, @send_info = {}, {}
    @save_info[:msg] = text[0...1024]
    @save_info[:to_number] = @send_info[:from_number] = dest
    @save_info[:from_number] = @send_info[:to_number] = source
    message_words = text.strip.split(/\s+/)
    if (vhd = Vhd.find_by_mobile(source))
      [@save_info, @send_info].each { |h| h[:project] = vhd.project }
      #XXX: temp code
      Message.save_from_person(vhd, @save_info)
      @send_info[:msg] = "The SMS system is temporarily closed. We are sorry for the inconvenience."
      Message.send_to_person(vhd, @send_info)
      vhd.update_attributes(:status => "vacant")
      #XXX: end temp code
      #handle_text_from_vhd(vhd, message_words)
    elsif (doctor = Doctor.find_by_mobile(source))
      [@save_info, @send_info].each { |h| h[:project] = doctor.project }
      #XXX: temp code
      Message.save_from_person(doctor, @save_info)
      #XXX: end temp code
      #handle_text_from_doctor(doctor, message_words)
    else
      handle_unregistered(location)
    end
    render :nothing => true
  end

  # This is a function specified to SMS Gup Shup where they update the status
  # of the message in real time. The response url is editable on their site.
  def delivery_status
    # Params available: externalId, deliveredTS, status, phoneNo, cause
    external_id = params[:externalId] || ''
    status = params[:status] || ''
    delivered_time = params[:deliveredTS] || ''
    cause = params[:cause] || ''
    
    message = Message.find_by_external_id(external_id.strip)
    unless message.nil?
      status = status.strip.upcase
      if status == "SUCCESS"
        integer_time = delivered_time[0...-3].to_i
	message.time_delivered = Time.at(integer_time).utc.to_datetime
	message.gateway_status = "Delivered"
      else
	message.gateway_status = cause.strip.capitalize
      end
      message.save
    end
    render :nothing => true
  end

  private

    def handle_unregistered(location)
      if Project.where("mobile = ?", @save_info[:to_number]).count == 1
        project = Project.find_by_mobile(@save_info[:to_number])
      elsif Project.where("location = ?", location).count == 1
        project = Project.find_by_location(location)
      else
        project = nil
      end
      [@save_info, @send_info].each { |h| h[:project] = project }
      Message.save_from_person(nil, @save_info)
      #XXX: temp code
      msg = "The SMS system is temporarily closed. We are sorry for the inconvenience."
      #msg = (project ? project.unregistered_msg : DEFAULT_UNREGISTERED_MSG)
      #XXX: end temp code
      @send_info[:msg] = msg
      Message.send_to_person(nil, @send_info)
    end

    def handle_text_from_vhd(vhd, message_words)
      if duplicate_msg(vhd, @save_info[:msg])
        Message.save_from_person(vhd, @save_info)
      elsif vhd.status == "deleted"
        # TODO: send an appropriate message
        Message.save_from_person(vhd, @save_info)
      elsif vhd.status == "deactivated"
        # TODO: send an appropriate message
        Message.save_from_person(vhd, @save_info)
      elsif vhd.is_patient
        handle_text_from_patient_vhd(vhd, message_words)
      elsif message_words[0].match(/req/i) && vhd.project.has_reqs
        handle_req(vhd, message_words)
      elsif message_words[0].match(/ans/i) && vhd.project.has_ans
        handle_ans(vhd, message_words)
      else
        Message.save_from_person(vhd, @save_info)
	    @send_info[:msg] = vhd.project.req_format_msg
	    Message.send_to_person(vhd, @send_info)
        vhd.update_attributes(:status => "vacant")
      end
    end

    def handle_text_from_patient_vhd(vhd, message_words)
      if vhd.project.has_hlps
        handle_hlp(vhd, message_words)
      else
        Message.save_from_person(vhd, @save_info)
	    @send_info[:msg] = DEFAULT_NO_PATIENTS_MSG
	    Message.send_to_person(vhd, @send_info)
        vhd.update_attributes(:status => "vacant")
      end
    end

    def handle_hlp(vhd, message_words)
      # the <= 0 is because the decrementing happens after the fin
      if vhd.is_patient_buyer && vhd.buyer_count <= 0
        Message.save_from_person(vhd, @save_info)
	    @send_info[:msg] = DEFAULT_NO_POINTS_MSG
        Message.send_to_person(vhd, @send_info)
        return
      end
      if message_words[0].match(/hlp/i)
        kase = Case.new_case_from_vhd(vhd)
	    [@save_info, @send_info].each { |h| h[:case] = kase }
	    Message.save_from_person(vhd, @save_info)
        Pm.notify("hlp", kase)
	    doctors_to_page = vhd.project.get_doctors_to_page(kase)
	    doctors_to_page.each { |d| d.page(kase) }
      else
        Message.save_from_person(vhd, @save_info)
	    @send_info[:msg] = vhd.project.hlp_format_msg
	    Message.send_to_person(vhd, @send_info)
      end
    end


    def handle_req(vhd, message_words)
      if check_req_format(message_words)
	    patient = create_patient_for_vhd(vhd, message_words)
	    kase = Case.new_case_from_vhd(vhd, patient)
	    [@save_info, @send_info].each { |h| h[:case] = kase }
	    Message.save_from_person(vhd, @save_info)
	    Pm.notify("req", kase)
	    doctors_to_page = vhd.project.get_doctors_to_page(kase)
	    doctors_to_page.each { |d| d.page(kase) }
      else
        Message.save_from_person(vhd, @save_info)
	    @send_info[:msg] = vhd.project.req_format_msg
	    Message.send_to_person(vhd, @send_info)
      end
      vhd.update_attributes(:status => "vacant")
    end

    ## TODO: Incomplete!!!!
    def handle_ans(vhd, message_words)
      Message.save_from_person(@save_info)
  #    if vhd.status == "scribed" # vhd's status is scribed
  #      # read the letter and get a case
  #      # forward to the doctor if there is a case
  #      # send reply options if there is not a case
  #    else
  #      if # it's unambiguous
  #        # forward to the doctor
  #        vhd.update_attributes(:status => "vacant")
  #      else
  #        # has cases ? send options & status = scribed : send back no options
  #      end
  #    end
    end

    def handle_text_from_doctor(doctor, message_words)
      if duplicate_msg(doctor, @save_info[:msg])
        Message.save_from_person(doctor, @save_info)
      elsif doctor.status == "deleted"
        # TODO: send an appropriate message
        Message.save_from_person(doctor, @save_info)
      elsif doctor.status == "deactivated"
        # TODO: send an appropriate message
        Message.save_from_person(doctor, @save_info)
      elsif message_words[0].match(/acc/i)
        if message_words[1].nil?
	      handle_acc_without_letter(doctor)
	    else
	      letter = message_words[1].first.upcase
	      handle_acc_with_letter(doctor, letter)
	    end
      elsif message_words[0].match(/fin/i)
        handle_fin(doctor, message_words)
      # TODO: make work with VHD scribed
      else
        unless doctor.current_case.nil?
	      kase = doctor.current_case
	      [@save_info, @send_info].each { |h| h[:case] = kase }
	      Message.save_from_person(doctor, @save_info)
	      message_for_vhd = [ "For patient", kase.patient.name, ":", 
	        Code.expand(@save_info[:msg]), ":" , "Dr.", doctor.name, 
	        doctor.mobile ].compact.join(" ")
	      @send_info.delete(:to_number)
	      @send_info[:msg] = kase.fin_for_vhd
	      Message.send_to_person(kase.vhd, @send_info)
	    else
	      Message.save_from_person(doctor, @save_info)
	    end
      end
    end

    def handle_acc_without_letter(doctor)
      kase = doctor.next_open_case
      unless kase.nil?
	    Message.save_from_person(doctor, @save_info.merge(:case => kase))
	    kase.handle_case_with_acc(doctor)
      else
        Message.save_from_person(doctor, @save_info)
	    response = [ "Sorry Dr. #{doctor.last_name}.", 
	      "No cases are available at this time." ].join(" ")
	    Message.send_to_person(doctor, @send_info.merge(:msg => response))
      end
    end

    def handle_acc_with_letter(doctor, letter)
      kase = doctor.case_on_letter(letter)
      unless kase.nil?
	    [@save_info, @send_info].each { |h| h[:case] = kase }
	    Message.save_from_person(doctor, @save_info)
        if kase.status != "opened"
	      response = [ "Sorry Dr. #{doctor.last_name}.", 
	      kase.unavailable_response, doctor.acc_options ].compact.join(" ")
	      Message.send_to_person(doctor, @send_info.merge(:msg => response))
	    else
	      kase.handle_case_with_acc(doctor)
	    end
      else
	    Message.save_from_person(doctor, @save_info)
	    response = [ "Sorry Dr. #{doctor.last_name}.", 
	      "That case does not exist.", doctor.acc_options ].compact.join(" ")
	    Message.send_to_person(doctor, @send_info.merge(:msg => response))
      end
    end

    def handle_fin(doctor, message_words)
      kase = doctor.current_case
      unless kase.nil?
        if kase.vhd.is_patient_buyer
          old_buyer_count = kase.vhd.buyer_count
          kase.vhd.update_attributes(:buyer_count => old_buyer_count - 1)
        end
	    [@save_info, @send_info].each { |h| h[:case] = kase }
        Message.save_from_person(doctor, @save_info)
	    # TODO: check for an exact repeat req sms
	    @send_info.delete(:to_number)
	    @send_info[:msg] = kase.fin_for_vhd
	    Message.send_to_person(kase.vhd, @send_info)
	    Pm.notify("fin", kase)
	    kase.resolve
	    doctor.update_attributes(:status => "available")
      else
        Message.save_from_person(doctor, @save_info)
	    doctor.update_attributes(:status => "available")
      end
    end

    # TODO: def handle_scribed(doctor, text, message_words); end

    # This function looks for other cases with the same exact req sms
    def no_repeat_cases(kase)
      repeats = Message.where("msg = :content AND case_id != :case_id",
	   { :content => kase.messages.first.msg, :case_id => kase.id })
      if !repeats.empty?
        other_cases = repeats.map { |mess| mess.case }
	other_cases.each do |other_case|
          if other_case.status == "accepted" || other_case.status == "scribed"
	    update_case_status(other_case, "closed")
	  elsif other_case.status == "closed"
	    return false # there is a repeat case that was closed
	  end
	end
      else
        return true
      end
    end

    # duplicate_msg looks to see if the exact same message was sent to the
    # the system in the last 30 minutes. In which case, we are assuming that
    # the gateway/network is spitting that message twice (accidentally)
    def duplicate_msg(person, msg)
      thirty_mins_ago = 30.minutes.ago.utc.to_datetime
      query = "from_person_id = :id AND from_person_type = :class AND msg = :msg
        AND time_received_or_sent > :thirty_mins_ago"
      data = { :id => person.id, :class => person.class.to_s, :msg => msg,
        :thirty_mins_ago => thirty_mins_ago }
      return true if Message.where(query, data).count > 0
      return false
    end

end
