module PaymentStateMachine
  def self.included(base)
    
    base.state_machine :initial => :queued do
      after_transition any => any, :do => :log_payment_event
      after_transition :queued => :processing, :do => :call_remote_dwolla_api
      after_transition :processing => :completed, :do => :complete_records
      after_transition :processing => :duplicate, :do => :cancel_duplicate
      after_transition all => :error, :do => :set_account_error

      event :process do  
        transition :queued => :processing
      end

      event :complete do
        transition :processing => :completed
      end

      event :handle_error do
        transition all - [:queued, :error] => :error
      end

      event :cancel do
        transition all => :cancelled
      end
      
      event :handle_duplicate do
        transition :processing => :duplicate
      end
    end
    
  end
end