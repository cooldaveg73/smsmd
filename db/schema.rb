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

ActiveRecord::Schema.define(:version => 20120722202623) do

  create_table "apms", :id => false, :force => true do |t|
    t.integer  "id",                       :null => false
    t.string   "first_name", :limit => 20
    t.string   "last_name",  :limit => 20
    t.string   "mobile",     :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  create_table "blocks", :id => false, :force => true do |t|
    t.integer  "id",         :null => false
    t.string   "name"
    t.integer  "apm_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cases", :id => false, :force => true do |t|
    t.integer  "id",                                    :null => false
    t.string   "status",                  :limit => 10
    t.integer  "followed_up"
    t.integer  "fake"
    t.integer  "success"
    t.integer  "alerted"
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

  create_table "codes", :id => false, :force => true do |t|
    t.integer  "id",           :null => false
    t.string   "abbreviation"
    t.string   "expansion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "districts", :id => false, :force => true do |t|
    t.integer  "id",         :null => false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "doctors", :id => false, :force => true do |t|
    t.integer  "id",                                            :null => false
    t.string   "first_name",       :limit => 20
    t.string   "last_name",        :limit => 20
    t.string   "mobile",           :limit => 20
    t.datetime "last_paged"
    t.string   "specialty",        :limit => 20
    t.integer  "hospital_id"
    t.integer  "active"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "points",                         :default => 0
    t.datetime "points_timestamp"
    t.string   "status",           :limit => 24
  end

  create_table "hospitals", :id => false, :force => true do |t|
    t.integer  "id",         :null => false
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

  create_table "messages", :id => false, :force => true do |t|
    t.integer  "id",                                    :null => false
    t.integer  "incoming"
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

  create_table "paging_records", :id => false, :force => true do |t|
    t.integer  "id",               :null => false
    t.integer  "case_id"
    t.integer  "paging_scheme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paging_schemes", :id => false, :force => true do |t|
    t.integer  "id",                           :null => false
    t.integer  "project_id"
    t.integer  "priority"
    t.integer  "doctor_id"
    t.integer  "random_doctor", :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "panchayats", :id => false, :force => true do |t|
    t.integer  "id",         :null => false
    t.string   "name"
    t.integer  "phc_id"
    t.integer  "block_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "patients", :id => false, :force => true do |t|
    t.integer  "id",                       :null => false
    t.string   "first_name", :limit => 20
    t.string   "last_name",  :limit => 20
    t.integer  "age"
    t.string   "meta_age"
    t.string   "mobile",     :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "registered"
  end

  create_table "phcs", :id => false, :force => true do |t|
    t.integer  "id",                           :null => false
    t.string   "name"
    t.string   "contact_name"
    t.string   "contact_number", :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pms", :id => false, :force => true do |t|
    t.integer  "id",                       :null => false
    t.string   "first_name", :limit => 20
    t.string   "last_name",  :limit => 20
    t.string   "mobile",     :limit => 20
    t.integer  "active"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :id => false, :force => true do |t|
    t.integer  "id",                                                                                                                                                                                                                                                   :null => false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "has_reqs",                                                            :default => 0
    t.integer  "has_hlps",                                                            :default => 0
    t.integer  "include_doctor_name",                                                 :default => 1
    t.integer  "include_doctor_mobile",                                               :default => 1
    t.string   "mobile",                :limit => 24,                                 :default => "9223173098"
    t.string   "unregistered_msg",      :limit => 1024,                               :default => "You have not been registered into the system. Please contact your hospital or project manager for registration."
    t.string   "close_msg",             :limit => 1024,                               :default => "Ye Case, Patient |PATIENT| ki liye, bund hogaya. Apko kisi karan is case ka jawab nahi mile aur abhi bhi jewab ke jerurat he tho dubara REQ ka sms kare."
    t.string   "req_format_msg",        :limit => 1024,                               :default => "Sorry, wrong format. Please re-send in this way: REQ (patient good name) (patient surname) (patient age (40y, A, C, I, E, P)) (patient mobile) (patient symptoms)"
    t.decimal  "time_zone",                             :precision => 3, :scale => 1
    t.string   "location",              :limit => 24
    t.integer  "has_patient_buyers"
    t.integer  "has_doctor_game"
    t.string   "hlp_format_msg",        :limit => 1024
    t.integer  "has_ans"
    t.boolean  "medgle_on",                                                           :default => false
  end

  create_table "promoters", :force => true do |t|
    t.string   "name",         :limit => 128
    t.string   "organization", :limit => 32
    t.string   "industry",     :limit => 32
    t.string   "country",      :limit => 32
    t.string   "website",      :limit => 1024
    t.string   "email",        :limit => 128
    t.string   "username",     :limit => 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key",          :limit => 1024
    t.integer  "project_id"
  end

  create_table "shifts", :id => false, :force => true do |t|
    t.integer  "id",           :null => false
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

  create_table "users", :id => false, :force => true do |t|
    t.integer  "id",                             :null => false
    t.string   "name"
    t.string   "hashed_password"
    t.string   "salt"
    t.integer  "is_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",           :limit => 256
    t.integer  "new_project_id"
  end

  create_table "vhds", :id => false, :force => true do |t|
    t.integer  "id",                                              :null => false
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
    t.integer  "is_patient",                       :default => 0
    t.integer  "doctor_id"
    t.string   "department",       :limit => 24
    t.string   "status",           :limit => 24
    t.integer  "is_patient_buyer"
    t.integer  "buyer_count"
  end

  create_table "villages", :id => false, :force => true do |t|
    t.integer  "id",                         :null => false
    t.string   "name",         :limit => 32
    t.integer  "panchayat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
