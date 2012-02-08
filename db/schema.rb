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
    t.string  "access_token",       :null => false
    t.string  "pin"
    t.integer "current_payment_id"
    t.string  "state"
  end

  create_table "payment_events", :force => true do |t|
    t.integer  "payment_id"
    t.datetime "created_at"
    t.string   "from_state"
    t.string   "to_state"
    t.string   "remote_transaction_id"
    t.text     "raw_response"
    t.text     "error"
  end

  add_index "payment_events", ["payment_id"], :name => "index_payment_events_on_payment_id"

  create_table "payments", :force => true do |t|
    t.integer  "account_id"
    t.datetime "effective_at"
    t.datetime "started_at"
    t.string   "state"
    t.datetime "completed_at"
  end

  add_index "payments", ["account_id", "started_at"], :name => "index_payments_on_account_id_and_started_at"

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

end
