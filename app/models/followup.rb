# == Schema Information
#
# Table name: followups
#
#  id                       :integer(4)      not null, primary key
#  case_id                  :integer(4)
#  patient_gender           :string(10)
#  days_sick                :integer(4)
#  still_sick               :boolean(1)
#  within_24_hours          :boolean(1)
#  followed_advice          :boolean(1)
#  followed_advice_comments :string(20)
#  would_use_again          :boolean(1)
#  patient_work             :string(20)
#  patient_family_size      :integer(4)
#  patient_family_income    :integer(4)
#  talked_with              :string(20)
#  case_is_real             :boolean(1)
#  case_is_real_comments    :string(40)
#  general_comments         :string(255)
#  symptoms                 :text
#  patient_did              :text
#  doctor_recommended       :text
#  created_at               :datetime
#  updated_at               :datetime
#

class Followup < ActiveRecord::Base

     belongs_to :case
     belongs_to :patient
     belongs_to :doctor
     belongs_to :project

     serialize :symptoms
     serialize :patient_did
     serialize :doctor_recommended


end
