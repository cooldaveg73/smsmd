
# Weird syntax with x_mins_ago: fifteen_mins_ago is the point in
# time that was fifteen_mins_ago. So any time before that is at
# least fifteen minutes ago ('<')

# Task: refresh_scribed_vhds
# update the status of vhd's who did not reply when they were scribed
thirty_mins_ago = 30.minutes.ago.utc.to_datetime
Vhd.where('status = "scribed"').each do |v|
  last_message = v.from_messages.last
  if last_message && last_message.time_sent < thirty_mins_ago
    v.update_attributes(:status => "vacant")
  end
end

# Task: close_accepted_cases_with_no_answer
# send close message after 40 minutes; actually close case after 120 minutes
forty_mins_ago = 40.minutes.ago.utc.to_datetime
one_twenty_mins_ago = 120.minutes.ago.to_datetime
cases_criteria = 'time_accepted < ? AND status IN ("accepted", "scribed")'
Case.where(cases_criteria, one_twenty_mins_ago).each { |c| c.close }
to_send_message_cases = Case.where(cases_criteria, forty_mins_ago)
Case.where(cases_criteria, forty_mins_ago).each { |c| c.send_close_message }

# Task: make_doctors_available
# has a safety check to make sure doctors last_paged 150 minutes ago are fixed
thirty_mins_ago = 30.minutes.ago.utc.to_datetime
one_fifty_mins_ago = 150.minutes.ago.utc.to_datetime
criteria = [ '(last_paged < :thirty_mins_ago AND status = "opened")',
  "last_paged < :one_fifty_mins_ago AND status IN (:stati)" ].join(" OR ")
data = { :thirty_mins_ago => thirty_mins_ago, :stati => %w(accepted scribed),
  :one_fifty_mins_ago => one_fifty_mins_ago }
Doctor.where(criteria, data).each do |d| 
  d.update_attributes(:status => "available")
end

# Task: close_opened_cases_with_no_response
# open cases close after sixty minutes
sixty_mins_ago = 60.minutes.ago.utc.to_datetime
criteria = 'status = "opened" AND time_opened < ?'
opened_cases = Case.where(criteria, sixty_mins_ago)
opened_cases.each { |c| c.close }

# Task: acc_reminder
five_mins_ago = 5.minutes.ago.utc.to_datetime
fifteen_mins_ago = 15.minutes.ago.utc.to_datetime
cases_criteria = 'status = "accepted" AND time_accepted > ?'
Case.where(cases_criteria, fifteen_mins_ago).each do |c|
  if c.doctor.status == "accepted" && c.doctor.last_paged < five_mins_ago
    Message.send_to_person(c.doctor, {:msg => c.acc_reminder, :case => c})
  end
end

# Task: alert pms
forty_mins_ago = 40.minutes.ago.utc.to_datetime
criteria = 'time_opened < ? AND status = "opened"'
open_cases = Case.where(cases_criteria, forty_mins_ago)
Case.where(criteria, forty_mins_ago).each do |c|
  unless c.alerted
    Pm.notify("alert", c)
    c.update_attributes(:alerted => true)
  end
end

# Task: page doctors
forty_mins_ago = 40.minutes.ago.utc.to_datetime
ten_mins_ago = 10.minutes.ago.utc.to_datetime
cases_criteria = ['status = "opened"', "time_opened > :forty_mins_ago",
		  "last_message_time < :ten_mins_ago"].join(" AND ")
cases_data = { :ten_mins_ago => ten_mins_ago, 
               :forty_mins_ago => forty_mins_ago }
Case.where(cases_criteria, cases_data).each do |kase|
  kase.project.get_doctors_to_page(kase).each { |d| d.page(kase) }
end

# Task: clear old demoer data
three_hours_ago = 3.hours.ago.utc.to_datetime
Demoer.where("updated_at < ?", three_hours_ago).destroy_all
