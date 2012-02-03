class AddAccountAmounts < ActiveRecord::Migration
  def up
    create_table :account_amounts do |t|
      t.integer  :account_id, :nil => false
      t.datetime :active_at, :nil => false
      t.float    :amount, :nil => false
    end
    
    add_index :account_amounts, [:account_id, :active_at]
  end

  def down
    drop_table :account_amounts
  end
end
