class Payment < ActiveRecord::Base
  include PaymentStateMachine
  
  belongs_to :account
  has_many :payment_events
  
  validates_presence_of :account_id, :started_at, :effective_at
  
  attr_accessor :raw_response, :remote_transaction_id, :error
  
  def log_payment_event(transition)
    payment_events.create!(:created_at => Time.now, 
                           :from_state => transition.from_name, 
                           :to_state => transition.to_name, 
                           :remote_transaction_id => remote_transaction_id, 
                           :raw_response => raw_response,
                           :error => error)
    raw_response = nil
    remote_transaction_id = nil
    error = nil
  end
  
  private
  
  def call_remote_dwolla_api(args)
    begin
      amount = account.scheduled_amount_at(effective_at).amount
      # call the dwolla api
      complete!
    rescue Exception => ex
      self.error = {:exception => ex.inspect, :trace => ex.backtrace}
      handle_error!
    end
  end
  
  def complete_records(args)
    update_attributes(:completed_at => Time.now)
    account.complete_transaction!
  end
  
  def set_account_error(args)
    account.handle_error!
  end
  
end