module PaymentStateMachine
  def self.included(base)
    
    base.state_machine :initial => :queued do
      after_transition any => any, :do => :log_payment_event
      after_transition :queued => :processing, :do => :call_remote_dwolla_api
      after_transition :processing => :completed, :do => :complete_records
      after_transition all => :error, :do => :set_account_error

      event :process do  
        transition :queued => :processing
      end

      event :complete do
        transition :processing => :completed
      end

      event :handle_error do
        transition all => :error
      end

      event :cancel do
        transition all => :cancelled
      end
    end
    
  end
end