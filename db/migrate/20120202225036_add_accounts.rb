class AddAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string   :access_token, :null => false
      t.string   :pin
      t.integer  :current_payment_id
      t.string   :state
    end
  end

  def self.down
    drop_table  :accounts
  end
end
