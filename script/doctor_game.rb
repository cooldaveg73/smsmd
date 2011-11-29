### Script to run the doctor game. This is to be run at 6 AM on Mondays. The
# messages will not be sent until after 9 AM.

# Task: Initializers
fin_points = 8
acc_points = 3
scribed_points = 8
dropped_points = -4
# key is doctor ===> links to :saved_timstamp, :saved_points, :patients_helped
@doctor_hash = {}
@prize_points = [ 250, 800, 1600, 2400, 4300 ]
@prize_descriptions = { 250 =>	"Rs. 500 Gift Card",
                        800 =>	"Rs. 1,200 Gift Card",
			1600 =>	"Rs. 2,000 Gift Card",
			2400 =>	"Rs. 3,000 Gift Card",
			4300 =>	"Dinner at Tag Hotel Restaurant (Rs. 5000)" }
default_stamp = Time.utc(2011, 8, 15, 3).to_datetime
#####################################################


# Task: Generate the updated data for the message
query = "status NOT IN ('deactivated','deleted')"
doctors = Project.find_by_name("Udaipur").doctors.where(query)
doctors.each do |doctor|
  doctor.points_timestamp = default_stamp if doctor.points_timestamp.nil?
  query = 'status = "resolved" AND time_accepted > ?', doctor.points_timestamp
  patients_helped = doctor.cases.where(*query).count
  @doctor_hash[doctor] = { :saved_timestamp => doctor.points_timestamp,
                           :saved_points => doctor.points, 
                           :patients_helped => patients_helped }
  query = "time_received_or_sent > ?", doctor.points_timestamp
  doctor.from_messages.where(*query).each do |message|
    message_words = message.msg.strip.split(/\s+/)
    if message_words[0].match(/acc/i)
      if message.case.nil? || message.case.status != "closed"
        doctor.points += acc_points
      else
	doctor.points += dropped_points
      end
    elsif message_words[0].match(/fin/i)
      doctor.points += fin_points unless message.case.nil?
    else
      if !message.case.nil? && message.case.last_doctor_msg != message.msg
	doctor.points += scribed_points
      else
        doctor.points += fin_points
      end
    end
  end
  doctor.points = 0 if doctor.points < 0
  doctor.points_timestamp = DateTime.now.new_offset(0)
  doctor.save
end
#####################################################


# Task: generate send the message
##
# Example: Thank you Doctor #Suman# for this week's activity with 
# Mobilizing Health!\nYou have helped #58 patients# since #August 23rd#!\n
# You now have #2350# points and need #only 50 points# to earn 
# the #Rs. 3,000 Gift Card#.
def active_message(doctor)
  patients_helped = @doctor_hash[doctor][:patients_helped]
  patients_helped = "#{patients_helped} patients"
  patients_helped = "1 patient" if patients_helped == "1 patients"
  points = doctor.points
  include_only = false
  next_prize = @prize_points[0]
  @prize_points.each_index do |n| 
    next_prize = @prize_points[n] if points > @prize_points[n - 1] unless n == 0
    break if points < @prize_points[n]
  end
  points_to_earn_prize = next_prize - points
  include_only = true if points_to_earn_prize <= 100
  points_to_earn_prize = "#{points_to_earn_prize} points"
  points_to_earn_prize = "1 point" if points_to_earn_prize == "1 points"
  time = @doctor_hash[doctor][:saved_timestamp]
  formatted_time = [ time.strftime("%B"), time.day.ordinalize ].join(" ")

  message = [ "Thank you Doctor", doctor.last_name,
              "for this week's activity with Mobilizing Health!\n",
	      "You have helped", patients_helped, "since",
	      formatted_time + "!\n", "You now have", doctor.points, 
	      "points and", include_only ? "only need" : "need", 
	      points_to_earn_prize, "to earn the", 
	      @prize_descriptions[next_prize] + "." ].join( " ")
  return message
end

# Example: Hi Doctor #David#. It looks like you weren't able to give
# your final recommendation for any patients this week. Please let us know
# if you have any concerns. You have #15# points.
def inactive_message(doctor)
  time = @doctor_hash[doctor][:saved_timestamp]
  formatted_time = [ time.strftime("%B"), time.day.ordinalize ].join(" ")
  message = [ "Hi Doctor", doctor.last_name + ".", 
  "It looks like you weren't able to give your final recommendation for any patients since", 
              formatted_time + ".", 
	      "Please let us know if you have any concerns.",
              "You have", doctor.points, "points." ].join(" ")
  return message
end

doctors.each do |doctor|
  doctor.reload
  if DateTime.now.new_offset(+5.5/24).hour >= 9
    if @doctor_hash[doctor][:patients_helped] == 0
      Message.send_to_person(doctor, {:msg => inactive_message(doctor)})
    else
      Message.send_to_person(doctor, {:msg => active_message(doctor)})
    end
  else
    sleep(200)
  end
end
#####################################################


# Task: send out prize messages when needed
@doctor_hash.each_key do |doctor|
  new_points = doctor.reload.points
  old_points = @doctor_hash[doctor][:saved_points]
  @prize_points.each_index do |n|
    if new_points > @prize_points[n] && old_points < @prize_points[n]
      message_for_doctor = [ "Congratulations Doctor", doctor.last_name + ".", 
      "Due to your dedication to helping patients through our system, you have been awarded a",
		 	     @prize_descriptions[@prize_points[n]] + ".",
      "Please contact your local project manager to collect your prize." 
                            ].join(" ")
      Message.send_to_person(doctor, {:msg => message_for_doctor})
      doctor.project.pms.each do |pm|
        message_for_pm = [ "**NOTE**", message_for_doctor ].join(" ")
	send_info = { :msg => message_for_pm, :project => doctor.project }
        Message.send_to_person(pm, send_info)
      end
    end
  end
end
#####################################################
