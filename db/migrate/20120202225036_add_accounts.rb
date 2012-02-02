class AddAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string   :access_token, :null => false
      t.string   :pin
      t.datetime :processed_at
    end
  end

  def self.down
    drop_table  :accounts
  end
end
