class AddTransactionLogs < ActiveRecord::Migration
  def up
    create_table :transaction_logs do |t|
      t.integer  :account_id, :nil => false
      t.datetime :started_at, :nil => false
      t.datetime :completed_at, :nil => false
      t.string   :remote_transaction_id, :nil => false
      t.text     :raw_response, :nil => false
      t.boolean  :is_successful, :nil => false, :default => true
    end
    
    add_index :transaction_logs, [:account_id, :started_at]
  end

  def down
    drop_table :transaction_logs
  end
end
