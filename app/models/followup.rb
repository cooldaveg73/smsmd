# == Schema Information
#
# Table name: followup
#
#  id         				:integer(4) not null, primary key
#  case_id                		:integer(4)
#  patient_gender 			:string(10) "male", "female", "pregnant"
#  days_sick 		 		:integer(4)
#  still_sick				:boolean(1)
#  within_24_hours			:boolean(1)
#  followed_advice			:boolean(1)
#  followed_advice_comments		:string(20) "chose not to pay", "inability to pay", "did not trust", "travel time", "other"	
#  would_use_again			:boolean(1)
#  patient_work				:string(20) "agriculture", "government work scheme", "social worker", "student", "child", "other", "followed all advice"
#  patient_family_size			:integer(4)
#  patient_family_income		:integer(4)
#  talked_with				:string(20) "patient", "vhd", "family member", "other"	  
#  case_is_real				:boolean(1)
#  case_is_real_comments		:string(20)
#  general_comments			:string(255)
#  symptoms				:text "Fever", "Cough", "Cold", "Head Ache", "Stomach Ache", "Rash", "Diarrhea", + user specified
#  patient_did				:text  "Tablets", "Syrup", "Injections", "See PHC", "Hospital", "At Home" "Quack Doctor", "Medical Dispensary", + user specified
#  doctor_recommended			:text

class Followup < ActiveRecord::Base

     belongs_to :case
     belongs_to :patient
     belongs_to :doctor
     belongs_to :project

     serialize :symptoms
     serialize :patient_did
     serialize :doctor_recommended


end
