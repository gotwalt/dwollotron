class AddAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer  :external_service_id, :null => false
      t.string   :access_token, :null => false
      t.string   :pin
      t.integer  :current_payment_id
      t.string   :state
    end
    
    add_index :accounts, :external_service_id
    
  end

  def self.down
    drop_table  :accounts
  end
end
