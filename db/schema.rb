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

ActiveRecord::Schema.define(:version => 20101026204822) do

  create_table "burns", :force => true do |t|
    t.string   "state"
    t.datetime "burn_date"
    t.string   "job_id"
    t.string   "message"
    t.text     "directory_files"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "burns", ["content_id"], :name => "index_burns_on_content_id"
  add_index "burns", ["job_id"], :name => "index_burns_on_job_id"
  add_index "burns", ["state"], :name => "index_burns_on_state"

  create_table "contents", :force => true do |t|
    t.datetime "found_date"
    t.string   "destination_folder"
    t.string   "state"
    t.string   "cadre_title"
    t.string   "directory_hash"
    t.string   "content_type"
    t.string   "media"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message"
    t.integer  "folder_id"
    t.datetime "archived_date"
  end

  add_index "contents", ["cadre_title"], :name => "index_contents_on_cadre_title"
  add_index "contents", ["destination_folder"], :name => "index_contents_on_destination_folder"
  add_index "contents", ["folder_id"], :name => "index_contents_on_folder_id"
  add_index "contents", ["state"], :name => "index_contents_on_status"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "folders", :force => true do |t|
    t.string   "folder"
    t.string   "media"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type"
  end

  add_index "folders", ["folder"], :name => "index_folders_on_folder"
  add_index "folders", ["media"], :name => "index_folders_on_media"
  add_index "folders", ["title"], :name => "index_folders_on_title"

  create_table "transcodes", :force => true do |t|
    t.string   "directory"
    t.datetime "completed"
    t.integer  "series_total"
    t.datetime "started"
    t.string   "type"
    t.integer  "series_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                              :default => "",   :null => false
    t.string   "role"
    t.boolean  "active",                             :default => true
    t.string   "encrypted_password",  :limit => 128, :default => "",   :null => false
    t.string   "password_salt",                      :default => "",   :null => false
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
