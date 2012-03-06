# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120302061019) do

  create_table "apms", :force => true do |t|
    t.string   "first_name", :limit => 20
    t.string   "last_name",  :limit => 20
    t.string   "mobile",     :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  create_table "blocks", :force => true do |t|
    t.string   "name"
    t.integer  "apm_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cases", :force => true do |t|
    t.string   "status",                  :limit => 10
    t.boolean  "followed_up"
    t.boolean  "fake"
    t.boolean  "success"
    t.boolean  "alerted"
    t.integer  "doctor_id"
    t.integer  "vhd_id"
    t.integer  "patient_id"
    t.datetime "time_opened"
    t.datetime "time_accepted"
    t.datetime "time_closed_or_resolved"
    t.datetime "last_message_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "tag"
  end

  add_index "cases", ["doctor_id"], :name => "index_cases_on_doctor_id"
  add_index "cases", ["project_id"], :name => "index_cases_on_project_id"
  add_index "cases", ["vhd_id"], :name => "index_cases_on_vhd_id"

  create_table "codes", :force => true do |t|
    t.string   "abbreviation"
    t.string   "expansion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "demoers", :force => true do |t|
    t.string   "mobile"
    t.string   "demoer_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "acc",         :default => false
  end

  create_table "districts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "doctors", :force => true do |t|
    t.string   "first_name",       :limit => 20
    t.string   "last_name",        :limit => 20
    t.string   "mobile",           :limit => 20
    t.datetime "last_paged"
    t.string   "specialty",        :limit => 20
    t.integer  "hospital_id"
    t.boolean  "active"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "points",                         :default => 0
    t.datetime "points_timestamp"
    t.string   "status",           :limit => 24
  end

  add_index "doctors", ["project_id"], :name => "index_doctors_on_project_id"

  create_table "followups", :force => true do |t|
    t.integer  "case_id"
    t.string   "patient_gender",           :limit => 10
    t.integer  "days_sick"
    t.boolean  "still_sick"
    t.boolean  "within_24_hours"
    t.boolean  "followed_advice"
    t.string   "followed_advice_comments", :limit => 20
    t.boolean  "would_use_again"
    t.string   "patient_work",             :limit => 20
    t.integer  "patient_family_size"
    t.integer  "patient_family_income"
    t.string   "talked_with",              :limit => 20
    t.boolean  "case_is_real"
    t.string   "case_is_real_comments",    :limit => 40
    t.string   "general_comments"
    t.text     "symptoms"
    t.text     "patient_did"
    t.text     "doctor_recommended"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hospitals", :force => true do |t|
    t.string   "name"
    t.integer  "village_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.string   "person_type"
    t.integer  "person_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.boolean  "incoming"
    t.string   "msg",                   :limit => 1024
    t.string   "from_number",           :limit => 20
    t.string   "from_person_type",      :limit => 8
    t.string   "to_number",             :limit => 20
    t.string   "to_person_type",        :limit => 8
    t.integer  "case_id"
    t.datetime "time_received_or_sent"
    t.string   "external_id"
    t.string   "gateway_status"
    t.datetime "time_delivered"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "from_person_id"
    t.integer  "to_person_id"
  end

  add_index "messages", ["case_id"], :name => "index_messages_on_case_id"
  add_index "messages", ["from_person_id"], :name => "index_messages_on_from_person_id"
  add_index "messages", ["from_person_type"], :name => "index_messages_on_from_person_type"
  add_index "messages", ["project_id"], :name => "index_messages_on_project_id"
  add_index "messages", ["to_person_id"], :name => "index_messages_on_to_person_id"
  add_index "messages", ["to_person_type"], :name => "index_messages_on_to_person_type"

  create_table "notify_schemes", :force => true do |t|
    t.integer  "pm_id"
    t.integer  "project_id"
    t.string   "alert_type", :limit => 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paging_records", :force => true do |t|
    t.integer  "case_id"
    t.integer  "paging_scheme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paging_schemes", :force => true do |t|
    t.integer  "project_id"
    t.integer  "priority"
    t.integer  "doctor_id"
    t.boolean  "random_doctor", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "panchayats", :force => true do |t|
    t.string   "name"
    t.integer  "phc_id"
    t.integer  "block_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "patients", :force => true do |t|
    t.string   "first_name", :limit => 20
    t.string   "last_name",  :limit => 20
    t.integer  "age"
    t.string   "meta_age"
    t.string   "mobile",     :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "registered"
  end

  create_table "phcs", :force => true do |t|
    t.string   "name"
    t.string   "contact_name"
    t.string   "contact_number", :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pms", :force => true do |t|
    t.string   "first_name", :limit => 20
    t.string   "last_name",  :limit => 20
    t.string   "mobile",     :limit => 20
    t.boolean  "active"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_reqs",                                                            :default => false
    t.boolean  "has_hlps",                                                            :default => false
    t.boolean  "include_doctor_name",                                                 :default => true
    t.boolean  "include_doctor_mobile",                                               :default => true
    t.string   "mobile",                :limit => 24,                                 :default => "9223173098"
    t.string   "unregistered_msg",      :limit => 1024,                               :default => "You have not been registered into the system. Please contact your hospital or project manager for registration."
    t.string   "close_msg",             :limit => 1024,                               :default => "Ye Case, Patient |PATIENT| ki liye, bund hogaya. Apko kisi karan is case ka jawab nahi mile aur abhi bhi jewab ke jerurat he tho dubara REQ ka sms kare."
    t.string   "req_format_msg",        :limit => 1024,                               :default => "Sorry, wrong format. Please re-send in this way: REQ (patient good name) (patient surname) (patient age (40y, A, C, I, E, P)) (patient mobile) (patient symptoms)"
    t.decimal  "time_zone",                             :precision => 3, :scale => 1
    t.string   "location",              :limit => 24
    t.boolean  "has_patient_buyers"
    t.boolean  "has_doctor_game"
    t.string   "hlp_format_msg",        :limit => 1024
  end

  create_table "shifts", :force => true do |t|
    t.integer  "start_hour"
    t.integer  "start_minute"
    t.integer  "start_second"
    t.integer  "end_hour"
    t.integer  "end_minute"
    t.integer  "end_second"
    t.integer  "doctor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "hashed_password"
    t.string   "salt"
    t.boolean  "is_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vhds", :force => true do |t|
    t.string   "first_name",       :limit => 20
    t.string   "last_name",        :limit => 20
    t.string   "mobile",           :limit => 20
    t.string   "notes",            :limit => 1024
    t.integer  "village_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "phc_id"
    t.boolean  "is_patient",                       :default => false
    t.integer  "doctor_id"
    t.string   "department",       :limit => 24
    t.string   "status",           :limit => 24
    t.boolean  "is_patient_buyer"
    t.integer  "buyer_count"
  end

  add_index "vhds", ["project_id"], :name => "index_vhds_on_project_id"

  create_table "villages", :force => true do |t|
    t.string   "name",         :limit => 32
    t.integer  "panchayat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
