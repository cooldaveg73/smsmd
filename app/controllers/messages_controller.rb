class MessagesController < ApplicationController
  include MessagesHelper

  skip_before_filter :authorize,
                     :only => [:sms_responder, :delivery_status, :send_sms]

  def messages
    redirect_to :root
    return
    @mobile = params[:mobile]
    current_page = params[:page].to_i
    person = person_on_phone_num(@mobile)
    unless person.class == Pm
      authorize_project(person.project)
    else
      if person.projects.count == 1
        authorize_project(person.projects.first)
      end
    end
    per_page_count = 100
    conditions = "from_number = :mobile OR to_number = :mobile"
    data = { :mobile => @mobile }
    begin_index = current_page * per_page_count
    @messages = Message.where(conditions, data).order("id DESC").offset(begin_index).limit(per_page_count)
    total = Message.where(conditions, data).count
    @prev_page, @next_page = get_pages(current_page, per_page_count, total)
    @timezone = +5.5
    @title = "Messages: #{person.name}"
    @subtitle = "#{person.project.name} Project"
    render :layout => "sortable_table"
  end

  def send_sms
    dest = params[:dest] || ""
    message = params[:message] || ""
    message = message.strip()[0...160]
    sending_status = "Message could not be delivered to smsgupshup."
    sending_success = false
    # /d{10} is a ten-digit number
    if dest.match(/\d{10}/)
      sending_status = "Message successfully delivered."
      sending_success = true
      vhd = Vhd.find_by_mobile(dest)
      unless vhd.nil?
        if Message.send_to_vhd(vhd, message).external_id.nil?
	  sending_status = "Message could not be delivered to Gateway."
	  sending_success = false
	end
      else
	doctor = Doctor.find_by_mobile(dest)
	unless doctor.nil?
	  if Message.send_to_doctor(doctor, message).external_id.nil?
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
    if(vhd = Vhd.find_by_mobile(source))
      [@save_info, @send_info].each { |h| h[:project] = vhd.project }
      handle_text_from_vhd(vhd, message_words)
    elsif(doctor = Doctor.find_by_mobile(source))
      [@save_info, @send_info].each { |h| h[:project] = doctor.project }
      handle_text_from_doctor(doctor, message_words)
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
      msg = (project ? project.unregistered_msg : DEFAULT_UNREGISTERED_MSG)
      @send_info[:msg] = msg
      Message.send_to_person(nil, @send_info)
    end

    def handle_text_from_vhd(vhd, message_words)
      if message_words[0].match(/req/i)
	handle_req(vhd, message_words)
      elsif message_words[0].match(/ans/i)
        handle_ans(vhd, message_words)
      else
        Message.save_from_person(vhd, @save_info)
	@send_info[:msg] = vhd.project.req_format_msg
	Message.send_to_person(vhd, @send_info)
        vhd.update_attributes(:status => "vacant")
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
      if message_words[0].match(/acc/i)
        if message_words[1].nil?
	  handle_acc_without_letter(doctor)
	else
	  letter = message_words[1].first.upcase
	  handle_acc_with_letter(doctor, letter)
	end
      elsif message_words[0].match(/fin/i)
        handle_fin(doctor, message_words)
      else
	# TODO: make work with VHD scribed
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

end
