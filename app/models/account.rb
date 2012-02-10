class Account < ActiveRecord::Base
  include AccountStateMachine
  include DwollaAccount
  
  validates_presence_of :access_token
  has_many :scheduled_amounts
  has_many :scheduled_withdrawals
  
  has_many :payments
  
  scope :waiting, where(:state => :waiting)
  
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
    raise InvalidStateError unless self.payment_completed?
    raise ArgumentError if current_payment.nil?# || current_payment.state != :completed
    self.update_attributes!(:current_payment_id => nil)
    @current_payment = nil
    finalize_records!
  end
  
  def cancel_current_payment(args = nil)
    raise InvalidStateError if self.waiting?
    destroy_current_payment
    reset_after_cancel
  end
  
  def reset_payments_after_error(args = nil)
    raise InvalidStateError unless self.error?
    destroy_current_payment
  end
  
  def enqueue_payment(args = nil)
    Resque.enqueue(PaymentProcessor, current_payment.id)
  end
  
  class InvalidStateError < StandardError
  end
  
  private
  
  def destroy_current_payment
    current_payment.cancel! if current_payment.present?
    self.update_attributes!(:current_payment_id => nil)
    @current_payment = nil
  end
  
end