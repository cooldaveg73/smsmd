class ReportingController < ApplicationController
  include ReportingHelper

  def new
    @project = get_project_and_set_subtitle
    time = parse_time(params[:time])
    current_time = DateTime.now.new_offset(+5.5/24)
    month_start = Time.at(time).in_time_zone(+5.5).beginning_of_month
    @is_current = (month_start.to_i == current_time.beginning_of_month.to_i)

    @month_and_year_display = Time.at(time).strftime("%B %Y")
    @date_display = current_time.strftime("%A, %d %B %Y")
    @time_display = current_time.strftime("%r IST")

    @prev_time = Time.at(time).months_ago(1).to_i
    @next_time = Time.at(time).months_since(1).to_i

    set_project_data(time)
    @active_vhd_info = []
    @active_doctor_info = []
    active_vhds = get_active_vhds(time)
    active_vhds.each { |vhd| @active_vhd_info << get_vhd_info(vhd, time) }
    active_doctors = get_active_doctors
    active_doctors.each do |doctor| 
      @active_doctor_info << get_doctor_info(doctor, time)
    end
    @title = "Reporting and Diagnostics"
  end

  private

    def get_doctor_info(doctor, time)
      beginning_of_month = Time.at(time).beginning_of_month.utc.to_datetime
      end_of_month = Time.at(time).end_of_month.utc.to_datetime
      args = beginning_of_month, end_of_month
      query = [ "from_doctor_id = ?", "time_received_or_sent > ?", 
                "time_received_or_sent < ?" ].join(" AND ")
      num_acc = num_submitted = num_fin = 0
      Message.where(query, doctor.id, *args).each do |message|
        unless message.msg.nil?
	  first_word = message.msg.strip.split(/\s+/).first
	  if first_word.match(/acc/i)
	    num_acc += 1
	  elsif first_word.match(/fin/i)
	    num_fin += 1
	  else
	    num_submitted += 1
	  end
	end
      end
      query = ["time_opened > ?", "time_opened < ?", 'status = "resolved"',
               "time_accepted IS NOT NULL",
	       "time_closed_or_resolved IS NOT NULL" ].join(" AND ")
      cases = doctor.cases.where(query, *args)
      sum = 0
      cases.each do |kase|
        sum += kase.time_resolved.to_i - kase.time_accepted.to_i
      end
      unless cases.count == 0
	average_response_time = (sum / 60.0 / cases.count).round(ROUND)
      end
      hsh = { :doctor => doctor, :number_of_acc => num_acc, 
              :number_of_fin => num_fin, 
	      :number_of_submitted => num_submitted,
	      :average_response_time => average_response_time || nil }
      return hsh
    end

    def get_active_doctors
      @project.doctors.where("active = ?", true)
    end

    def get_vhd_info(vhd, time)
      beginning_of_month = Time.at(time).beginning_of_month.utc.to_datetime
      end_of_month = Time.at(time).end_of_month.utc.to_datetime
      args = beginning_of_month, end_of_month
      query = "time_opened > ? AND time_opened < ?"
      cases_in_month = vhd.cases.where(query, *args)
      query = [ "from_vhd_id = ?", "time_received_or_sent > ?", 
                "time_received_or_sent < ?" ].join(" AND ")
      messages_count = Message.where(query, vhd.id, *args).count
      fake_messages_count = cases_in_month.where("fake = ?", true).count

      hsh =  { :vhd => vhd, :case_count => cases_in_month.count,
               :message_count => messages_count, 
	       :fake_message_count => fake_messages_count }
      return hsh
    end

    # defining active vhds as vhds in project with a message this month
    def get_active_vhds(time)
      end_of_month = Time.at(time).end_of_month.utc.to_datetime
      beginning_of_month = Time.at(time).beginning_of_month.utc.to_datetime
      active_vhds = []
      @project.vhds.each do |vhd|
        query = [ "from_vhd_id = ?", "time_received_or_sent > ?", 
	          "time_received_or_sent < ?" ].join(" AND ")
	args = vhd.id, beginning_of_month, end_of_month
        active_vhds << vhd if Message.where(query, *args).count > 0
      end
      return active_vhds
    end

    def parse_time(time_input)
      time = time_input.to_i
      if time == 0 || time > Time.now.to_i || @project.cases.empty?
	time = Time.now.to_i
      elsif time < @project.cases.first.time_opened.to_i
	time = @project.cases.first.time_opened.to_i
      end
      return time
    end

    def set_project_data(time)
      return get_current_data(time) if @is_current
      @cases_today = @cases_per_day_week = NO_ENTRY
      @fake_today = @fake_week = NO_ENTRY
      @doc_response_today = @doc_response_week = NO_ENTRY
      return get_old_data(time)
    end

    def get_current_data(time)
      days_in_project = days_from_start(time)
      cases = @project.cases
      @cases_per_day_all = (cases.count.to_f / days_in_project).round(ROUND)
      @fake_all = cases.where("fake = 1").count
      @doc_response_all = get_doctor_response(cases)

      start_of_month, days_in_month = get_start_of_month(time)
      cases = cases.where("time_opened >= ?", start_of_month)
      @cases_per_day_month = (cases.count.to_f / days_in_month).round(ROUND)
      @fake_month = cases.where("fake = 1").count
      @doc_response_month = get_doctor_response(cases)

      start_of_week, days_in_week = get_start_of_week(time)
      cases = cases.where("time_opened >= ?", start_of_week)
      @cases_per_day_week = (cases.count.to_f / days_in_week).round(ROUND)
      @fake_week = cases.where("fake = 1").count
      @doc_response_week = get_doctor_response(cases)

      start_of_day = get_start_of_day(time)
      cases = cases.where("time_opened >= ?", start_of_day)
      if cases.count == 0
	@cases_today = @fake_today = @doc_response_today = "no cases today"
      else
	@cases_today = cases.count
	@fake_today = cases.where("fake = 1").count
	@doc_response_today = get_doctor_response(cases)
      end
    end

    def get_old_data(time)
      end_of_month = Time.at(time).end_of_month.utc.to_datetime
      days_in_project = days_from_start(end_of_month.to_i)
      cases = @project.cases.where("time_opened < ?", end_of_month)
      @cases_per_day_all = (cases.count.to_f / days_in_project).round(ROUND)
      @fake_all = cases.where("fake = 1").count
      @doc_response_all = get_doctor_response(cases)

      start_of_month, days_in_month = get_start_of_month_old(time)
      cases = cases.where("time_opened > ?", start_of_month)
      @cases_per_day_month = (cases.count.to_f / days_in_month).round(ROUND)
      @fake_month = cases.where("fake = 1").count
      @doc_response_month = get_doctor_response(cases)
    end

    def days_from_start(time)
      return 1 if @project.cases.empty?
      start_time = @project.cases.first.time_opened
      seconds_from_start = time.to_i - start_time.to_i
      return (seconds_from_start.to_f / SECONDS_PER_DAY).ceil
    end
    
    def get_start_of_month(time)
      return [get_start_of_day(time), 1] if @project.cases.empty?
      start_of_month = Time.at(time).beginning_of_month.utc.to_datetime
      first_case = @project.cases.first 
      if first_case.time_opened > start_of_month
	return [first_case.time_opened, days_from_start(time)]
      else
	days_in_month = Time.at(time).day
	return [start_of_month, days_in_month]
      end
    end

    def get_start_of_month_old(time)
      start_of_month = Time.at(time).beginning_of_month.utc.to_datetime
      next_month = Time.at(time).months_since(1)
      start_of_next_month = next_month.beginning_of_month.utc.to_datetime
      first_case_time = @project.cases.first.time_opened
      start_of_month = first_case_time if first_case_time > start_of_month
      seconds_in_month = start_of_next_month.to_i - start_of_month.to_i
      days_in_month = seconds_in_month / SECONDS_PER_DAY
      days_in_month = 1 if days_in_month == 0
      return [start_of_month, days_in_month]
    end

    def get_start_of_day(time)
      return Time.at(time).beginning_of_day.utc.to_datetime
    end

    def get_start_of_week(time)
      return [get_start_of_day(time), 1] if @project.cases.empty?
      start_of_week = Time.at(time).beginning_of_week.utc.to_datetime
      first_case = @project.cases.first 
      if first_case.time_opened > start_of_week
	return [first_case.time_opened, days_from_start(time)]
      else
	days_in_week = Time.at(time).wday
	days_in_week = 7 if days_in_week == 0
	return [start_of_week, days_in_week]
      end
    end

  def get_doctor_response(cases)
    return NO_ENTRY if cases.empty?
    sum_in_seconds = 0
    conditions = "time_accepted IS NOT NULL AND time_opened IS NOT NULL"
    cases.where(conditions).each do |kase|
      sum_in_seconds += (kase.time_accepted.to_i - kase.time_opened.to_i)
    end
    return (sum_in_seconds / 60.0 / cases.count).round(ROUND)
  end


end
