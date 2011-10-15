module MessagesHelper

  def check_req_format(message_words)
    return false if message_words.size < 5
    second_word = message_words[1] # patient's good name
    third_word = message_words[2] # patient's surname
    fourth_word = message_words[3] # patient's age or meta-age
    fifth_word = message_words[4] # patient's mobile

    # name_regex allows for one non-whitespace-character in the middle
    name_regex = /\A[a-zA-z]+\S?[a-zA-Z]*\z/i
    # age_regex must start with one or two digits or a meta age tag
    age_regex = /\A((\d|\d{2})\D*|(a|c|i|e|p))\z/i
    
    return false unless second_word.match(name_regex)
    return false unless third_word.match(name_regex)
    return false unless fourth_word.match(age_regex)
    return false unless fifth_word.match(/\d{10}/)

    return true
  end

  def create_patient_for_vhd(vhd, message_words)
    first_name = message_words[1].humanize
    last_name = message_words[2].humanize
    mobile = message_words[4].match(/\d{10}/).to_s
    patient = Patient.find_by_mobile(mobile)
    unless patient.nil?
      if patient.first_name == first_name && patient.last_name == last_name
	return patient
      end
    end
    age_text = message_words[3]
    meta_age = age = nil

    if age_text.match(/\A(a|c|i|e|p)\z/i)
      expansions = {"A" => "Adult", "C" => "Child", "I" => "Infant", 
		    "P" => "Pregnant Woman", "E" => "Elder"}
      meta_age = expansions[age_text.upcase]
    else
      age = age_text.match(/\d+/).to_s.to_i
    end
    patient = Patient.create(:first_name => first_name, :last_name => last_name,
      :mobile => mobile, :meta_age => meta_age, :age => age, 
      :project => vhd.project)
    return patient
  end

end
