require 'mysql2'
require 'sqlite3'
require 'date'
require 'set'

# TODO: Change values for development
mysql_db = Mysql2::Client.new(:database => "mobilehealth", :username => "root", :password => "8something")
sqlite_db=SQLite3::Database.new("/var/www/mh1.0/smsmd")

def create_pms()
pms = [["Sheela", "Rameshwar", "9529361881"],
  ["Yashoda", "Paniya", "9829597093"],
  ["Narmida", "Purbia", "8769855152"],
  ["Shashaank", "Thoda", "9167200702"]]

  pms.each do |pm|
    new_pm = Pm.new
    new_pm.first_name, new_pm.last_name, new_pm.mobile = pm
    new_pm.active = true
    new_pm.save!
  end
end

def migrate_mysql_panchayats(db)
  result = {}
  panchayats = db.query("select * from webapp_panchayat order by id")
  panchayats.each do |panchayat|
    new_panchayat = Panchayat.new
    new_panchayat.name = panchayat["name"].capitalize
    new_panchayat.save!
    result[panchayat["id"]] = new_panchayat
  end
  return result
end

def migrate_mysql_villages(db, mysql_panchayat_ids_to_new_panchayats)
  result = {}
  villages = db.query("select * from webapp_village order by id")
  villages.each do |village|
    new_village = Village.new
    new_village.name = village["name"].capitalize
    new_village.panchayat = mysql_panchayat_ids_to_new_panchayats[village["panchayat_id"]]
    new_village.save!
    result[village["id"]] = new_village
  end
  return result
end

def migrate_mysql_vhds(db, mysql_village_ids_to_new_villages)
  result = {}
  mysql_vhds = db.query("select * from webapp_vhd order by id")
  mysql_vhds.each do |mysql_vhd|
    vhd = Vhd.where(:mobile => mysql_vhd['phone_number'][2..-1])
    if vhd.length > 1 or vhd.length < 1
      if mysql_vhd["first_name"] == "Jeff"
        jeff = Vhd.find_by_first_name_and_last_name("Jeff", "Hsu")
        jeff.notes = mysql_vhd["extra_info"]
        jeff.village = mysql_village_ids_to_new_villages[mysql_vhd["village_id"]]
        jeff.save!
        result[mysql_vhd["id"]] = jeff
      elsif mysql_vhd["first_name"] == "Purbia"
        purbia = Vhd.find_by_first_name_and_last_name("Narmda", "Poorbia")
        purbia.notes = mysql_vhd["extra_info"]
        purbia.village = mysql_village_ids_to_new_villages[mysql_vhd["village_id"]]
        purbia.save!
        result[mysql_vhd["id"]] = purbia
      elsif mysql_vhd["first_name"] == "dhanraj"
        dhanraj = Vhd.find_by_first_name_and_last_name("Dhanraj", "Purohit")
        dhanraj.notes = mysql_vhd["extra_info"]
        dhanraj.village = mysql_village_ids_to_new_villages[mysql_vhd["village_id"]]
        dhanraj.save!
        result[mysql_vhd["id"]] = dhanraj
      else
        printf "Could not patch up DB for '%s' '%s' '%s'\n", mysql_vhd["first_name"], mysql_vhd["last_name"], mysql_vhd["phone_number"][2..-1]
      end
    else
      result[mysql_vhd["id"]] = vhd[0]
      vhd[0].village = mysql_village_ids_to_new_villages[mysql_vhd["village_id"]]
      vhd[0].notes = mysql_vhd["extra_info"]
      vhd[0].save!
    end
  end
  return result
end

def migrate_sqlite_doctors(db)
  result = {}
  doctors=db.execute("select firstname, lastname, cellphone, shiftx1, shifty1, shiftx2, shifty2, status, level, id from doctor order by id")
  doctors.each do |d|
    first_name, last_name, mobile, shiftx1, shifty1, shiftx2, shifty2, status, last_paged,id = d
    doctor_in_db = Doctor.find_by_mobile(mobile.to_s)
    if not doctor_in_db.nil?
      new_doctor = doctor_in_db
    else
      new_doctor = Doctor.new
      new_doctor.first_name = first_name
      new_doctor.last_name = last_name
      new_doctor.mobile = mobile
      new_doctor.save!
    end
    # The sqlite adapter assumes that datetimes are in UTC, which is wrong, so we take the string
    # we read in, tack on a time zone, and then parse it to a DateTime object.
    new_doctor.last_paged = DateTime.strptime(last_paged.strip + " +05:30", "%Y-%m-%d %H:%M:%S %Z")
    new_doctor.active = true
    new_doctor.status = status
    shifts = Array.new
    if !shiftx1.nil? && !shifty1.nil? && shiftx1.strip != '' && shifty1.strip != ''
      new_shift = Shift.new
      new_shift.start_hour = shiftx1.to_i
      new_shift.start_minute = 0
      new_shift.start_second = 0
      new_shift.end_hour = shifty1.to_i
      new_shift.end_minute = 59
      new_shift.end_second = 59
      new_shift.doctor = new_doctor
      new_shift.save!
      shifts.push(new_shift)
    end
    
    if !shiftx2.nil? && !shifty2.nil? && shiftx2.strip != '' && shifty2.strip != ''
      new_shift = Shift.new
      new_shift.start_hour = shiftx2.to_i
      new_shift.start_minute = 0
      new_shift.start_second = 0
      new_shift.end_hour = shifty2.to_i
      new_shift.end_minute = 59
      new_shift.end_second = 59
      new_shift.doctor = new_doctor
      new_shift.save!
      shifts.push(new_shift)
    end
    
    new_doctor.shifts = shifts
    new_doctor.save!
    result[id] = new_doctor
  end
  return result
end

def migrate_sqlite_codes(db)
  codes = db.execute("select code, med from prescription order by id")
  codes.each do |c|
    abbreviation, expansion = c
    new_code = Code.new
    new_code.abbreviation = abbreviation
    new_code.expansion = expansion
    new_code.save!
  end
end

def migrate_sqlite_vhds(db)
  vhds = db.execute("select firstname, lastname, cellphone, id from vhd order by id")
  result = {}
  vhds.each do |v|
    first_name, last_name, cell_phone, id = v
    new_vhd = Vhd.new
    new_vhd.first_name = first_name.capitalize
    new_vhd.last_name = last_name.capitalize
    new_vhd.mobile = cell_phone
    new_vhd.save!
    result[id] = new_vhd 
  end
  return result
end

def migrate_sqlite_cases(db, dr_map, vhd_map)
  result = {}
  cases = db.execute("select id, firstname, lastname, age, metaage, status, vhdid, drid, cellphone, level1, level2, level3 from cases order by id")
  cases.each do |cc|
    case_id, first_name, last_name, age, meta_age, status, vhd_id, dr_id, patient_mobile, time_opened, intr_time, time_closed = cc
    first_name = first_name.capitalize
    last_name = last_name.capitalize
    patient = Patient.find_or_create_by_first_name_and_last_name_and_mobile(first_name, last_name, patient_mobile)
    begin
      patient.age = age.to_i
    rescue
    end
    patient.meta_age = meta_age
    patient.save!
    c = Case.new
    c.patient = patient
    doc = dr_map[dr_id]
    vhd = vhd_map[vhd_id]
    c.doctor = doc
    c.vhd = vhd
    c.followed_up = false
    c.fake = false
    # TODO: Figure out how to set the .alerted field on this message
    unless status.nil?
      status = status.strip
      if status == "Opened"
        status = "Accepted"
      end
      if status == "Referred"
        status = "Opened"
      end
    end
    c.status = status
    c.time_opened = DateTime.parse(time_opened.strip + " +05:30", "%Y-%m-%d %H:%M:%S %Z")
    if !time_closed.nil? && time_closed.strip != ''
      c.time_closed = DateTime.parse(time_closed.strip + " +05:30", "%Y-%m-%d %H:%M:%S %Z")
    end
    if !intr_time.nil? && intr_time.strip != ''
      c.time_accepted = DateTime.parse(intr_time.strip + " +05:30", "%Y-%m-%d %H:%M:%S %Z")
    end
    c.save!
    result[case_id] = c
  end
  return result
end

def migrate_mysql_messages(db, mysql_caseids_to_new_cases)
  messages = db.query("select * from webapp_message order by id")
  messages.each do |old_message|
    m = Message.new
    m.from_number = old_message["phone_number"][2..-1]
    doctor_for_message = Doctor.find_by_mobile(m.from_number)
    if not doctor_for_message.nil?
      m.from_person_type = "doctor"
      m.from_doctor = doctor_for_message
    end
    
    vhd_for_message = Vhd.find_by_mobile(m.from_number)
    if not vhd_for_message.nil?
      m.from_person_type = "vhd"
      m.from_vhd = vhd_for_message
    end
    
    pm_for_message = Pm.find_by_mobile(m.from_number)
    if not pm_for_message.nil?
      m.from_person_type = "pm"
      m.from_pm = pm_for_message
      m.from_vhd = nil
    end
    
    if m.from_person_type.nil?
      m.from_person_type = "unknown"
    end
    
    m.to_person_type = "unknown"

    # The Mysql adapter assumes the times are in the local time zone, which is wrong, so we first
    # convert the date_time we read in to a string, tack on the time zone, and then parse it back
    # as a DateTime object.
    m.time_received = DateTime.strptime(old_message["date_time"].strftime("%Y-%m-%d %H:%M:%S").strip + " +05:30", "%Y-%m-%d %H:%M:%S %Z")
    m.msg = old_message["text"]
    m.case = mysql_caseids_to_new_cases[old_message["case_number"]]
    unless m.case.nil?
      if m.case.last_message_time.nil?
        m.case.last_message_time = m.time_received
        begin
          m.case.save!
        rescue
          # TODO
        end
      else
        if m.time_received > m.case.last_message_time
          m.case.last_message_time = m.time_received
          begin
            m.case.save!
          rescue
            # TODO
          end
        end
      end
    end
    m.save!
  end
end

def migrate_sqlite_messages(db, sqlite_caseids_to_new_cases)
  messages = db.execute("select id, src, dest, status, msg, term, level, caseid from openhealth order by id")
  messages.each do |old_message|
    id, src, dest, status, msg, term, time_received, old_case_id = old_message
    m = Message.new
    if status == "incoming"
      m.incoming = true
    else
      m.incoming = false
    end
    if m.incoming
      if not src.nil?
        m.from_number = src
      else
        m.from_number = dest
      end
      m.to_number = "9223173098"
    else
      m.to_number = dest
      m.from_number = "9223173098"
    end
    m.msg = msg
    if term == "xundef"
      term = "unknown"
    end
    if m.incoming
      m.from_person_type = term
      m.to_person_type = "system"
    else
      m.to_person_type = term
      m.from_person_type = "system"
    end
    if m.from_person_type == "doctor"
      m.from_doctor = Doctor.find_by_mobile(m.from_number)
    elsif m.from_person_type == "vhd"
      m.from_vhd = Vhd.find_by_mobile(m.from_number)
    elsif m.from_person_type == "pm"
      m.from_pm = Pm.find_by_mobile(m.from_number)
    end
    if m.to_person_type == "doctor"
      m.to_doctor = Doctor.find_by_mobile(m.to_number)
    elsif m.to_person_type == "vhd"
      m.to_vhd = Vhd.find_by_mobile(m.to_number)
    elsif m.to_person_type == "pm"
      m.to_pm = Pm.find_by_mobile(m.to_number)
    end
    # Same issue as above with sqlite adapter, so we have to fix that by tacking on the timezone.
    if m.incoming
      m.time_received = DateTime.parse(time_received.strip + " +05:30", "%Y-%m-%d %H:%M:%S %Z")
    else
      m.time_sent = DateTime.parse(time_received.strip + " +05:30", "%Y-%m-%d %H:%M:%S %Z")
    end
    if not old_case_id.nil? and old_case_id.to_s.strip != ''
      new_case = sqlite_caseids_to_new_cases[old_case_id]
      m.case = new_case
    end
    unless m.case.nil?
      if m.case.last_message_time.nil?
        m.case.last_message_time = m.time_received_or_sent
        begin
          m.case.save!
        rescue
          # TODO
        end
      else
        if m.time_received_or_sent > m.case.last_message_time
          m.case.last_message_time = m.time_received_or_sent
          begin
            m.case.save!
          rescue
            # TODO
          end
        end
      end
    end
    m.save!
  end
end

def migrate_mysql_doctors(db)
  result = {}
  doctors = db.query("select * from webapp_dr order by id")
  doctors.each do |doctor|
    new_doctor = Doctor.new
    new_doctor.first_name = doctor["first_name"].capitalize
    new_doctor.last_name = doctor["last_name"].capitalize
    new_doctor.mobile = doctor["phone_number"][2..-1]
    new_doctor.active = false
    new_doctor.save!
    result[doctor["id"]] = new_doctor
  end
  return result
end

def migrate_mysql_patients(db)
  result = {}
  name_regex = /[a-zA-Z]{2,}/
  num_regex = /[0-9]{5,}/
  patients = db.query("select * from webapp_patient order by id")
  patients.each do |patient|
    first_name = name_regex.match(patient["first_name"])
    last_name = name_regex.match(patient["last_name"])
    mobile = num_regex.match(patient["phone_number"])
    criteria = {}
    if not first_name.nil?
      criteria[:first_name] = first_name.to_s.capitalize
    else
      criteria[:first_name] = nil
    end
    if not last_name.nil?
      criteria[:last_name] = last_name.to_s.capitalize
    else
      criteria[:last_name] = nil
    end
    if not mobile.nil?
      criteria[:mobile] = mobile.to_s
    else
      criteria[:mobile] = nil
    end
    existing_patients = Patient.where(criteria)
    if existing_patients.size > 1
      printf "'%s','%s', '%s', '%s'\n", patient["id"], patient["first_name"], patient["last_name"], patient["phone_number"]
    else
      existing_patient = existing_patients[0]
      if existing_patient.nil?
        new_patient = Patient.new
        if not first_name.nil?
          new_patient.first_name = first_name.to_s.capitalize
        end
        if not last_name.nil?
          new_patient.last_name = last_name.to_s.capitalize
        end
        if not mobile.nil?
          new_patient.mobile = mobile.to_s
        end
        
        new_patient.save!
        existing_patient = new_patient
      end
      result[patient["id"]] = existing_patient
    end
  end
  return result
end

def migrate_mysql_cases(db, patient_map, dr_map, vhd_map)
  result = {}
  cases = db.query("select * from webapp_case order by case_number")
  cases.each do |kase|
    new_case = Case.new
    new_case.patient = patient_map[kase["patient_id"]]
    new_case.doctor = dr_map[kase["Dr_number"]]
    new_case.vhd = vhd_map[kase["VHD_number"]]
    new_case.status = "Closed"
    if not kase["successful"].nil?
      if kase["successful"] == 1
        new_case.success = true
      else
        new_case.success = false
      end
    end
    new_case.fake = false
    new_case.followed_up = false
    # TODO: Figure out how to set the .alerted field on this message
    if not kase['start_date_time'].nil?
      # Same issue as above with Mysql adapter.
      new_case.time_opened = DateTime.strptime(kase['start_date_time'].strftime("%Y-%m-%d %H:%M:%S").strip + " +05:30", "%Y-%m-%d %H:%M:%S %Z")
    end
    if not kase['end_date_time'].nil?
      # Same issue as above with Mysql adapter.
      new_case.time_closed = DateTime.strptime(kase['end_date_time'].strftime("%Y-%m-%d %H:%M:%S").strip + " +05:30", "%Y-%m-%d %H:%M:%S %Z")
    end
    new_case.save!
    result[kase["id"]] = new_case
  end
  return result
end

create_pms()

mysql_panchayat_ids_to_new_panchayats = migrate_mysql_panchayats(mysql_db)
mysql_village_ids_to_new_villages = migrate_mysql_villages(mysql_db, mysql_panchayat_ids_to_new_panchayats)
sqlite_vhd_ids_to_new_vhds = migrate_sqlite_vhds(sqlite_db)
mysql_vhd_ids_to_new_vhds = migrate_mysql_vhds(mysql_db, mysql_village_ids_to_new_villages)

mysql_dr_ids_to_new_doctors = migrate_mysql_doctors(mysql_db)
sqlite_dr_ids_to_new_doctors = migrate_sqlite_doctors(sqlite_db)
migrate_sqlite_codes(sqlite_db)

mysql_patient_ids_to_new_patients = migrate_mysql_patients(mysql_db)
mysql_caseids_to_new_cases = migrate_mysql_cases(mysql_db, mysql_patient_ids_to_new_patients, mysql_dr_ids_to_new_doctors, mysql_vhd_ids_to_new_vhds)
sqlite_caseids_to_new_cases = migrate_sqlite_cases(sqlite_db, sqlite_dr_ids_to_new_doctors, sqlite_vhd_ids_to_new_vhds)

migrate_mysql_messages(mysql_db, mysql_caseids_to_new_cases)
migrate_sqlite_messages(sqlite_db, sqlite_caseids_to_new_cases)
