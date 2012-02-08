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
  
  state_machine :initial => :waiting do
    before_transition :waiting => :queued, :do => :create_new_payment
    after_transition :queued => :transaction_completed, :do => :update_account_record
    before_transition :error => :waiting, :do => :cancel_current_payment
      
    event :queue do
      transition :waiting => :queued
    end
    
    event :complete_transaction do
      transition :queued => :transaction_completed
    end
    
    event :finalize_records do
      transition :transaction_completed => :waiting
    end
    
    event :handle_error do
      transition all => :error
    end
    
    event :recover_from_error do
      transition :error => :waiting
    end
    
    state :waiting do
      def create_new_payment(args = nil)
        raise ArgumentError unless self.current_payment_id.nil?
        payment = Payment.create!(:account_id => self.id, :started_at => Time.now, :effective_at => Time.now)
        self.update_attributes!(:current_payment_id => payment.id)
      end
    end
    
    state :finalize do
      def update_account_record(args = nil)
        raise ArgumentError if current_payment.nil?# || current_payment.state != :completed
        self.update_attributes!(:current_payment_id => nil)
        finalize_records!
      end
    end
    
    state :error do
      def cancel_current_payment(args = nil)
        raise ArgumentError if current_payment_id.nil?
        current_payment.cancel!
        self.update_attributes!(:current_payment_id => nil)
      end
    end
  end
end