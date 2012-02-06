class TransactionLog < ActiveRecord::Base
  belongs_to :account
  
  validates_presence_of :account_id, :started_at, :completed_at, :remote_transaction_id, :raw_response, :is_successful
  
end