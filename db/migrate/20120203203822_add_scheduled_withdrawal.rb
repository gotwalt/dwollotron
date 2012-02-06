class AddScheduledWithdrawal < ActiveRecord::Migration
  def up
    create_table :scheduled_withdrawals do |t|
      t.integer  :account_id, :nil => false
      t.datetime :effective_at, :nil => false
      t.integer  :day_of_month, :nil => false
    end
    
    add_index :scheduled_withdrawals, [:account_id, :effective_at]
  end

  def down
    drop_table :scheduled_withdrawals
  end
end
