# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20120203203822) do

  create_table "accounts", :force => true do |t|
    t.string   "access_token", :null => false
    t.string   "pin"
    t.datetime "processed_at"
  end

  create_table "scheduled_amounts", :force => true do |t|
    t.integer  "account_id"
    t.datetime "effective_at"
    t.float    "amount"
  end

  add_index "scheduled_amounts", ["account_id", "effective_at"], :name => "index_scheduled_amounts_on_account_id_and_effective_at"

  create_table "scheduled_withdrawals", :force => true do |t|
    t.integer  "account_id"
    t.datetime "effective_at"
    t.integer  "day_of_month"
  end

  add_index "scheduled_withdrawals", ["account_id", "effective_at"], :name => "index_scheduled_withdrawals_on_account_id_and_effective_at"

  create_table "transaction_logs", :force => true do |t|
    t.integer  "account_id"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.string   "remote_transaction_id"
    t.text     "raw_response"
    t.boolean  "is_successful",         :default => true
  end

  add_index "transaction_logs", ["account_id", "started_at"], :name => "index_transaction_logs_on_account_id_and_started_at"

end
