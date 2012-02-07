class Payment < ActiveRecord::Base
  belongs_to :account
  has_many :payment_events
  
  validates_presence_of :account_id, :started_at, :effective_at
  
  attr_accessor :raw_response, :remote_transaction_id
  
  def log_state_change!(transition)
    payment_events.create!(:created_at => Time.now, :from_state => transition.from_name, :to_state => transition.to_name, :remote_transaction_id => remote_transaction_id, :raw_response => raw_response)
  end
  
  state_machine :initial => :queued do
    
    around_transition do |payment, transition, block|
      payment.raw_response = nil
      payment.remote_transaction_id = nil
      block.call
      payment.log_state_change!(transition)
    end
    
    after_transition :queued => :processing, :do => :call_remote_dwolla_api
    after_transition :processing => :completed, :do => :complete_account!
    after_transition all => :error, :do => :set_account_error!
    event :process do  
      transition :queued => :processing
    end

    event :complete do
      transition :processing => :completed
    end

    event :error do
      transition all => :error
    end
    
    event :cancel do
      transition all => :cancelled
    end
    
    state :processing do
      def call_remote_dwolla_api(args)
        amount = account.scheduled_amount_at(effective_at)
        # do some other work
        if (false)
          error!
        else
          complete!
        end
      end
    end

    state :completed do
      def complete_account!(args)
        account.complete!
      end
    end

    state :error do
      def set_account_error!(args)
        account.error!
      end
    end

  end
  
end