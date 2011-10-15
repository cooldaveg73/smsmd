# requires a :status input
Factory.define :case do |f|
  f.vhd			{ |u| u.association(:vhd) }
  f.project		{ |u| u.vhd.project }
  f.followed_up		false
  f.fake		false
  f.alerted		false
  f.patient		{ |u| u.association(:patient) }
  f.after_create	do |u| 
    u.update_attributes(:tag => u.project.cases.count)
  end
end

Factory.define :newly_opened_case, :parent => :case do |f|
  f.status	"opened"
  f.sequence(:time_opened) do |n|
    time = DateTime.now.new_offset(+5.5/24)
    num_seconds = time.to_i - time.beginning_of_day.to_i
    time.beginning_of_day + (300 * n % num_seconds).seconds
  end
  f.after_create do |u| 
    Factory(:req_message, :case => u, :time_received => u.time_opened, 
      :from_person => u.vhd)
  end
end

Factory.define :opened_case, :parent => :newly_opened_case do |f|
  f.after_create do |u|
    (0..1).each do |num|
      Factory(:page_message, :case => u, 
        :time_sent => (num * 10).minutes + u.time_opened)
    end
  end
end

Factory.define :case_with_doctor, :parent => :newly_opened_case do |f|
  f.status	"accepted"
  f.doctor	{ |u| u.association(:doctor, :project => u.project) }
  f.after_create do |u|
    Factory(:page_message, :case => u, :time_sent => u.time_opened, 
      :to_person => u.doctor)
    Factory(:acc_message, :case => u, 
      :time_received => u.time_opened + 5.minutes, :from_person => u.doctor)
    Factory(:acc_response, :case => u, 
      :time_sent => u.time_opened + 5.minutes, :to_person => u.doctor)
    u.time_accepted = u.time_opened + 5.minutes
  end
end

Factory.define :finished_case, :parent => :case_with_doctor do |f|
  f.after_create do |u|
    last_message = u.messages.where("to_person_type = ?", "Doctor").last
    time_sent = last_message.time_sent + 5.minutes
    Factory(:fin_message, :time_sent => time_sent)
  end
end
