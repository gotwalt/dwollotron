class AddScheduledAmounts < ActiveRecord::Migration
  def up
    create_table :scheduled_amounts do |t|
      t.integer  :account_id, :nil => false
      t.datetime :effective_at, :nil => false
      t.float    :amount, :nil => false
    end
    
    add_index :scheduled_amounts, [:account_id, :effective_at]
  end

  def down
    drop_table :scheduled_amounts
  end
end
