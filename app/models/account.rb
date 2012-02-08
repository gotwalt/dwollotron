class Account < ActiveRecord::Base
  include AccountStateMachine
  
  validates_presence_of :access_token
  has_many :scheduled_amounts
  has_many :scheduled_withdrawals
  
  has_many :payments
  
  def current_amount
    scheduled_amount_at Time.now
  end
  
  def scheduled_amount_at(val)
    raise ArgumentError unless val.is_a?(Time)
    scheduled_amounts.effective_at(val).first
  end

  def current_withdrawal
    scheduled_withdrawal_at Time.now
  end
  
  def scheduled_withdrawal_at(val)
    raise ArgumentError unless val.is_a?(Time)
    scheduled_withdrawals.effective_at(val).first
  end
  
  def current_payment
    return nil if current_payment_id.nil?
    @current_payment ||= Payment.find(current_payment_id)
  end

  def create_new_payment(args = nil)
    raise InvalidStateError unless self.waiting?
    raise ArgumentError unless self.current_payment_id.nil?
    payment = Payment.create!(:account_id => self.id, :started_at => Time.now, :effective_at => Time.now)
    self.update_attributes!(:current_payment_id => payment.id)
  end
  
  def update_account_record(args = nil)
    raise InvalidStateError unless self.transaction_completed?
    raise ArgumentError if current_payment.nil?# || current_payment.state != :completed
    self.update_attributes!(:current_payment_id => nil)
    @current_payment = nil
    finalize_records!
  end
  
  def cancel_current_payment(args = nil)
    raise InvalidStateError unless self.error?
    raise ArgumentError if current_payment_id.nil?
    current_payment.cancel!
    self.update_attributes!(:current_payment_id => nil)
  end
  
  class InvalidStateError < StandardError
  end
  
end