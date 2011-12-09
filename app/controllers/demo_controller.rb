class DemoController < ApplicationController
  include MessagesHelper
  include DemoHelper
  skip_before_filter :authorize, :only => :new

  def new
    mobile = params[:mobile] || ""
    text = params[:text] || ""
    
    demoer = Demoer.find_by_mobile(mobile)
    unless demoer.nil?
      if demoer.demoer_type == "doctor"
	handle_doctor(demoer, text)
      elsif demoer.demoer_type == "vhd"
	handle_vhd(demoer, text)
      end
    end
    render :nothing => true
  end

  def setup
    @project = get_project_and_set_subtitle
    @receivers = Demoer.where("demoer_type = ?", "receiver")
    mobiles_in_project = @project.doctors.map { |doctor| doctor.mobile }
    demo_doctors = Demoer.where("demoer_type = ?", "doctor")
    @doctor_demo_mobiles = demo_doctors.map do |doctor|
      doctor.mobile unless mobiles_in_project.include?(doctor.mobile)
    end.compact
    mobiles_in_project = @project.vhds.map { |vhd| vhd.mobile }
    demo_vhds = Demoer.where("demoer_type = ?", "vhd")
    @vhd_demo_mobiles = demo_vhds.map do |vhd|
      vhd.mobile unless mobiles_in_project.include?(vhd.mobile)
    end
    demo_receivers = Demoer.where("demoer_type = ?", "receiver")
    @receiver_demo_mobiles = demo_receivers.map { |receiver| receiver.mobile }
    @title = "Demo"
  end

  def submit_doctors
    Demoer.where("demoer_type = ?", "doctor").destroy_all
    project = get_project_and_set_subtitle
    params[:doctors].each do |key, value|
      if value.match(/\d{10}/)
        Demoer.create(:mobile => value.match(/\d{10}/).to_s, 
	  :demoer_type => "doctor")
      else
        doctor = Doctor.find_by_id(key)
	if doctor && doctor.project == project
	  Demoer.create(:mobile => doctor.mobile, :demoer_type => "doctor")
	elsif value != ("" || nil)
	  Demoer.create(:mobile => value, :demoer_type => "doctor")
	end
      end
    end
    doctors_paged = []
    Demoer.where("demoer_type = ?", "doctor").each do |demo_doctor|
      external_id = Message.send_text(demo_doctor.mobile, PAGE_MSG)
      doctors_paged << demo_doctor.mobile unless external_id.nil?
    end
    flash[:notice] = [PAGE_MSG, "sent to", doctors_paged.join(", ")].join(" ")
    redirect_to "/demo"
  end

  def submit_vhds
    Demoer.where("demoer_type = ?", "vhd").destroy_all
    project = get_project_and_set_subtitle
    params[:vhds].each do |key, value|
      if value.match(/\d{10}/)
        Demoer.create(:mobile => value.match(/\d{10}/).to_s, 
	  :demoer_type => "vhd")
      else
        vhd = Vhd.find_by_id(key)
	if vhd && vhd.project == project
	  Demoer.create(:mobile => vhd.mobile, :demoer_type => "vhd")
	elsif value != ("" || nil)
	  Demoer.create(:mobile => value, :demoer_type => "vhd")
	end
      end
    end
    vhds_in_demo = []
    Demoer.where("demoer_type = ?", "vhd").each do |demo_vhd|
      vhds_in_demo << demo_vhd.mobile
    end
    flash[:notice] = [ vhds_in_demo.join(", "), "added to demo." ].join(" ")
    redirect_to "/demo"
  end

  def submit_receivers
    Demoer.where("demoer_type = ?", "receiver").destroy_all
    project = get_project_and_set_subtitle
    params[:receivers].each do |key, value|
      if value.match(/\d{10}/)
        Demoer.create(:mobile => value.match(/\d{10}/).to_s, 
	  :demoer_type => "receiver")
      end
    end
    redirect_to "/demo"
  end

  def destroy
    Demoer.destroy_all
    redirect_to "/demo"
  end

  private

    def handle_doctor(doctor, text)
      message_words = text.strip.split(/\s+/)
      # acc
      if message_words[0].match(/acc/i)
       if !message_words[1].nil? && message_words[1].first.upcase == "A"
	  Message.send_text(doctor.mobile, ACC_RESPONSE)
	  doctor.update_attributes(:acc => true)
	else
	  Message.send_text(doctor.mobile, WRONG_ACC_RESPONSE)
	  doctor.update_attributes(:acc => false)
	end
      # fin
      elsif doctor.acc? && message_words[0].match(/fin/i)
	send_to_receivers(fin_for_receiver(message_words))
	doctor.update_attributes(:acc => false)
      # scribed
      elsif doctor.acc?
        send_to_receivers(scribed_for_receiver(message_words))
      # other
      else
	Message.send_text(doctor.mobile, WRONG_ACC_RESPONSE)
      end
    end

    def send_to_receivers(text)
      Demoer.where('demoer_type = "receiver"').each do |receiver|
        Message.send_text(receiver.mobile, text)
      end
    end

    def handle_vhd(vhd, text)
      message_words = text.strip.split(/\s+/)
      if check_req_format(message_words)
        sleep(60)
	Message.send_text(vhd.mobile, ACC_FOR_VHD)
	sleep(120)
	Message.send_text(vhd.mobile, fin_for_vhd(message_words))
      else
        Message.send_text(vhd.mobile, DEFAULT_REQ_FORMAT_MSG)
      end
    end

    def fin_for_vhd(message_words)
      patient_name = [ message_words[1], message_words[2] ].join(" ")
      message = [ "Final recommendation for patient", patient_name, ":",
	Code.expand(FIN_FOR_VHD), "Dr. ----", "<Hospial>", "9011066359" 
	].join(" ")
      return message            
    end

    def scribed_for_receiver(message_words)
      message = [ "Recommendation for patient", "Anita", "Sondekar",
	Code.expand(message_words.join(" ")), ":", "Doctor ---", "9968686841",
	"<Hospital>" ].join(" ")
      return message
    end

    def fin_for_receiver(message_words)
      message = [ "Final recommendation for patient", "Anita", "Sondekar",
	Code.expand(message_words.join(" ")), ":", "Doctor ---", "9968686841", 
	"<Hospital>" ].join(" ")
      return message
    end

end
