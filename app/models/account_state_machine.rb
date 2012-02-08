module AccountStateMachine
  def self.included(base)
    
    base.state_machine :initial => :waiting do
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
  
end