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
        transition all - :waiting => :error
      end

      event :recover_from_error do
        transition :error => :waiting
      end

    end    
  end
  
end