class Account < ActiveRecord::Base
  
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
  
  def create_new_payment!
    raise ArgumentException unless self.current_payment_id.nil?
    
    payment = Payment.create!(:account_id => self.id, :started_at => Time.now, :effective_at => Time.now)
    self.update_attributes!(:current_payment_id => payment.id)
  end
  
  def clear_completed_payment!
    raise ArgumentError if current_payment.nil?# || current_payment.state != :completed
    self.update_attributes!(:current_payment_id => nil)
  end
  
  def cancel_current_payment!  
    raise ArgumentError if current_payment_id.nil?
    
    current_payment.cancel!
    self.update_attributes!(:current_payment_id => nil)
  end
  
  state_machine :initial => :waiting do
    before_transition :waiting => :queued, :do => :create_new_payment!
    after_transition :queued => :waiting, :do => :clear_completed_payment!
    after_transition :error => :waiting, :do => :cancel_current_payment!
      
    event :queue do
      transition :waiting => :queued
    end
    
    event :complete do
      transition :queued => :waiting
    end
    
    event :error do
      transition all => :error
    end
    
    event :recover_from_error do
      transition :error => :waiting
    end
  end
end