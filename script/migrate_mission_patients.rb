require 'sqlite3'
require 'date'

@db = SQLite3::Database.new("db/mission_patients")
$current_year = Time.now.year
$project_id = Project.find_by_name("Mission Hospital").id
$doc_bose_id = Doctor.find_by_last_name("Bose").id
$doc_jajodia_id = Doctor.find_by_last_name("Jajodia").id
$doc_sen_id = Doctor.find_by_last_name("Sen").id
$cardiac_depo = "cardiac"
$ortho_depo = "ortho"

def get_first_names(patient_names)
  patient_names.map do |fullname_string|
    words = fullname_string.split(/\s+/)
    words[0...words.size - 1].map { |word| word.humanize }.join(' ')
  end
end

def get_last_names(patient_names)
  patient_names.map do |fullname_string|
    words = fullname_string.split(/\s+/)
    words.last.humanize
  end
end

def get_ages(birthdays)
  birthdays.map do |birthday_string|
    if not birthday_string.blank?
      year = ("19" + birthday_string.split('.').first).to_i
      $current_year - year
    else
      nil
    end
  end
end

def get_db_info(info_name, table_name)
  info_arr = @db.execute("SELECT #{info_name} FROM #{table_name}")
  return info_arr.map { |elem| elem.to_s.strip }
end

def get_mobiles(mobiles)
  mobiles.map do |mobile_str|
    mobile_strings = mobile_str.split('/')
    if mobile_strings.empty? 
      nil
    elsif mobile_str.length != 10 && mobile_str.length != 21
      nil
    else
      mobile_str
    end
  end
end

def get_doctor_ids(doctors)
  doctors.map do |doctor_string|
    last_name = doctor_string.split(/\s+/).last
    if doctor_string.match(/sen/i)
      $doc_sen_id
    elsif doctor_string.match(/jajodia/i)
      $doc_jajodia_id
    else
      nil
    end
  end
end

def store_cardiac_patient_data(table_name)
  number_of_entries = get_db_info("COUNT(*)", table_name).first.to_i
  patient_names = get_db_info("patient_name", table_name)
  first_names = get_first_names(patient_names)
  last_names = get_last_names(patient_names)
  ages = get_ages( get_db_info("birthday", table_name) )
  mobiles = get_mobiles( get_db_info("mobile", table_name) )

  (0...number_of_entries).each do |index|
    if not mobiles[index].nil?
      mobiles_to_store = mobiles[index].split('/')
      mobiles_to_store.each do |mobile|
	patient = { :first_name => first_names[index], 
		    :last_name => last_names[index],
		    :mobile => mobile, :age => ages[index],
		    :project_id => $project_id, 
		    :department_name => $cardiac_depo,
		    :doctor_id => $doc_bose_id,
		    :registered => false }
	@patient_arr << patient
      end
    end
  end
end

def store_ortho_patient_data(table_name)
  number_of_entries = get_db_info("COUNT(*)", table_name).first.to_i
  patient_names = get_db_info("patient_name", table_name)
  first_names = get_first_names(patient_names)
  last_names = get_last_names(patient_names)
  ages = get_ages( get_db_info("birthday", table_name) )
  mobiles = get_mobiles( get_db_info("mobile", table_name) )
  doctor_ids = get_doctor_ids( get_db_info("doctor_name", table_name) )

  (0...number_of_entries).each do |index|
    if not mobiles[index].nil?
      mobiles_to_store = mobiles[index].split('/')
      mobiles_to_store.each do |mobile|
	patient = { :first_name => first_names[index], 
		    :last_name => last_names[index],
		    :mobile => mobile, :age => ages[index],
		    :project_id => $project_id, 
		    :department_name => $ortho_depo,
		    :doctor_id => doctor_ids[index], # this may be nil
		    :registered => false }
	@patient_arr << patient
      end
    end
  end
end


@patient_arr = []
store_cardiac_patient_data("cardiac_april")
store_cardiac_patient_data("cardiac_may")
store_ortho_patient_data("ortho_april")
store_ortho_patient_data("ortho_may")

@patient_arr.each do |patient_data|
  Patient.create!(patient_data)
end
