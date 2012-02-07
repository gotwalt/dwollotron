class AddPayments < ActiveRecord::Migration
  def up
    create_table :payments do |t|
      t.integer  :account_id, :nil => false
      t.datetime :effective_at, :nil => false
      t.datetime :started_at, :nil => false
      t.string   :state, :nil => false
      t.datetime :completed_at
    end
    
    create_table :payment_events do |t|
      t.integer  :payment_id, :nil => false
      t.datetime :created_at, :nil => false
      t.string   :from_state, :nil => false
      t.string   :to_state, :nil => false
      t.string   :remote_transaction_id
      t.text     :raw_response
    end
    
    add_index :payments, [:account_id, :started_at]
    add_index :payment_events, :payment_id
  end

  def down
    drop_table :payment_events
    drop_table :payments
  end
end
