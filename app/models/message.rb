# == Schema Information
#
# Table name: messages
#
#  id                    :integer(4)      not null, primary key
#  incoming              :boolean(1)
#  msg                   :string(1024)
#  from_number           :string(20)
#  from_person_type      :string(8)
#  to_number             :string(20)
#  to_person_type        :string(8)
#  case_id               :integer(4)
#  time_received_or_sent :datetime
#  external_id           :string(255)
#  gateway_status        :string(255)
#  time_delivered        :datetime
#  created_at            :datetime
#  updated_at            :datetime
#  project_id            :integer(4)
#  from_person_id        :integer(4)
#  to_person_id          :integer(4)
#

require 'net/http'
class Message < ActiveRecord::Base

  belongs_to :project
  belongs_to :case	
  belongs_to :from_person,	:polymorphic => true 
  belongs_to :to_person,	:polymorphic => true

  validates :msg, 		:length => { :maximum => 1024 }
  validates :from_person_type, 	:length => { :maximum => 8 }
  validates :to_person_type, 	:length => { :maximum => 8 }
  validates :from_number, 	:length => { :maximum => 20 }
  validates :to_number, 	:length => { :maximum => 20 }
  validates :gateway_status, 	:length => { :maximum => 255 }
  validates :external_id, 	:length => { :maximum => 255 }
  validates :incoming, 		:inclusion => { :in => [true,false] }

  alias_attribute :time_sent, :time_received_or_sent
  alias_attribute :time_received, :time_received_or_sent

  def self.send_to_person(person, send_info)
    rescue_send_info(person, send_info)
    args = [:to_number, :msg, :from_number].map { |i| send_info[i] }
    external_id = launch_msg(*args)
    # TODO: external_id.nil?
    time_sent = DateTime.now.new_offset(0)
    unless send_info[:case].nil?
      send_info[:case].update_attributes(:last_message_time => time_sent)
    end
    person.update_attributes(:last_paged => time_sent) if person.class == Doctor
    send_info.merge!(:incoming => false, :to_person => person, 
      :time_sent => time_sent, :external_id => external_id)
    create(send_info)
  end

  def self.save_from_person(person, save_info)
    time_received = DateTime.now.new_offset(0)
    unless save_info[:case].nil?
      save_info[:case].update_attributes(:last_message_time => time_received)
    end
    save_info.merge!(:incoming => true, :from_person => person,
      :time_received => time_received)
    create(save_info)
  end

  def self.send_text(mobile, text)
    external_id = launch_msg(mobile, text)
    # TODO: external_id.nil?
    puts "External id: #{external_id}" unless external_id.nil?
    return external_id
  end

  private

    def self.rescue_send_info(person, send_info)
      m = send_info
      m[:to_number] = person.mobile if m[:to_number].nil? unless person.nil?
      m[:project] = m[:case].project if m[:project].nil? unless m[:case].nil?
      unless m[:project].nil?
	m[:from_number] = m[:project].mobile if m[:from_number].nil?
      end
      m[:from_number] = DEFAULT_SYSTEM_NUM if m[:from_number].nil?
    end

    def self.launch_msg(dest, msg, phonecode=DEFAULT_SYSTEM_NUM)
      destination = "91" + dest
      if Rails.env.development? || Rails.env.test?
	if (vhd = Vhd.find_by_mobile(dest))
	  destination = "VHD: #{vhd.full_name}" unless vhd.nil?
	elsif (doctor = Doctor.find_by_mobile(dest))
	  destination = "Doctor: #{doctor.full_name}" unless doctor.nil?
	end
	printf("######Would send '%s' to '%s'\n", msg, destination)
	return nil
      end
      return send_msg(destination, msg, phonecode) if Rails.env.production?
    end

    def self.send_msg(dest, msg, phonecode)
      # SMSGupShup definition v1.0 Copyright
      @user = '2000069911'
      @pass = 'YQxgqTjFe'
      @host = 'xxx.msg4all.com'

      @port = '80'
      msg = URI.encode(msg)
      @post_ws = [ "/GatewayAPI/rest?v=1.1", "auth_scheme=PLAIN", 
        "method=sendMessage", "userid=2000037632", "password=b1izpV9yI", 
	"send_to=#{dest}", "msg_type=Text", "msg=#{msg}", "mask=#{phonecode}"
	].join("&")

      @payload = { "v" => "1.1", "method" => "sendMessage", 
        "auth_scheme" => "PLAIN", "userid" => "2000069911", 
	"password" => "YQxgqTjFe", "msg" => msg, "msg_type" => "Text",
	"send_to" => dest, "mask" => phonecode }

      req = Net::HTTP::Post.new(@post_ws, 
        initheader = "Content-type" => "application/x-www-form-urlencoded", 
	"Accept" => "text/plain")
      req.basic_auth @user, @pass
      req.body = @payload
      response = Net::HTTP.new(@host, @port).start { |http| http.request(req) }
      status, number, id = response.body.strip.split("|").map do |item| 
        item.strip
      end
      return nil if status == "error"
      return id
    end

end

