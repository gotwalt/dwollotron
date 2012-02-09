module AccountStateMachine
  def self.included(base)
    
    base.state_machine :initial => :waiting do
      before_transition :waiting => :queued, :do => :create_new_payment
      after_transition :waiting => :queued, :do => :enqueue_payment
      after_transition :queued => :payment_completed, :do => :update_account_record
      before_transition :error => :waiting, :do => :reset_payments_after_error
      
      event :queue do
        transition :waiting => :queued
      end

      event :complete_payment do
        transition :queued => :payment_completed
      end

      event :finalize_records do
        transition :payment_completed => :waiting
      end

      event :handle_error do
        transition all - [:waiting, :error] => :error
      end

      event :recover_from_error do
        transition :error => :waiting
      end
      
      event :reset_after_cancel do
        transition all => :waiting
      end

    end

  end
  
end