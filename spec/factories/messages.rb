def random_req_msg(patient_text=random_lorem)
  age_arr = ["a", "c", "e", "i", "p", "40y", "30"]
  return ["REQ", Factory(:patient).name, age_arr[rand(age_arr.count)],
          random_mobile, patient_text].join(" ")
end

def random_hlp_msg(patient_text=random_lorem)
  return ["HLP", patient_text].join(" ")
end

def random_fin_msg(treatment=random_lorem)
  return ["FIN", treatment].join(" ")
end

def random_time_today
  beginning_of_day = DateTime.now.new_offset(+5.5/24).beginning_of_day.to_i
  late_time = DateTime.now.to_i
  number_of_seconds = late_time - beginning_of_day
  return Time.at(beginning_of_day + number_of_seconds).utc.to_datetime
end

Factory.define :to_message, :class => "Message" do |f|
  f.incoming		false
  f.from_number		DEFAULT_SYSTEM_NUM
  f.time_sent		{ random_time_today }
end

Factory.define :from_message, :class => "Message" do |f|
  f.incoming		true
  f.to_number		DEFAULT_SYSTEM_NUM
  f.time_received	{ random_time_today }
end

Factory.define :to_doctor_message, :parent => :to_message do |f|
  f.to_person		{ |u| u.association(:doctor) }
  f.to_number		{ |u| u.to_person.mobile }
  f.project		{ |u| u.to_person.project }
end

Factory.define :from_doctor_message, :parent => :from_message do |f|
  f.from_person		{ |u| u.association(:doctor) }
  f.from_number		{ |u| u.from_person.mobile }
  f.project		{ |u| u.from_person.project }
end

# this must be called :case => :newly_opened_case in order to get proper msg
Factory.define :page_message, :parent => :to_doctor_message do |f|
  f.msg			{ |u| u.to_person.page_msg(u.case) }
  f.after_create do |u| 
    u.to_person.update_attributes(:status => "opened")
  end
end

Factory.define :from_vhd_message, :parent => :from_message do |f|
  f.from_person		{ |u| u.association(:vhd) }
  f.from_number		{ |u| u.from_person.mobile }
  f.project		{ |u| u.from_person.project }
end

Factory.define :to_vhd_message, :parent => :to_message do |f|
  f.to_person		{ |u| u.association(:vhd) }
  f.to_number		{ |u| u.to_person.mobile }
  f.project		{ |u| u.to_person.project }
end

Factory.define :req_message, :parent => :from_vhd_message do |f|
  f.msg	{ random_req_msg }
end

Factory.define :acc_message, :parent => :from_doctor_message do |f|
  f.case	{ |u| u.association(:opened_case) }
  f.msg	do |u| 
    [ "ACC", u.from_person.letter_on_case(u.case) ].join(" ")
  end
end

Factory.define :acc_response, :parent => :to_doctor_message do |f|
  f.case	{ |u| u.association(:case_with_doctor) }
  f.msg		{ |u| u.case.acc_for_doctor }
end

Factory.define :fin_message, :parent => :from_doctor_message do |f|
  f.msg		{ random_fin_msg }
end
