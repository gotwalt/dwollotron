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
end