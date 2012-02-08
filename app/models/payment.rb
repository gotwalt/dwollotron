class Payment < ActiveRecord::Base
  belongs_to :account
  has_many :payment_events
  
  validates_presence_of :account_id, :started_at, :effective_at
  
  attr_accessor :raw_response, :remote_transaction_id, :exception
  
  state_machine :initial => :queued do
    
    around_transition do |payment, transition, block|
      payment.raw_response = nil
      payment.remote_transaction_id = nil
      payment.exception = nil
      block.call
      payment.log_state_change!(transition)
    end
    
    after_transition :queued => :processing, :do => :call_remote_dwolla_api
    after_transition :processing => :completed, :do => :complete_records!
    after_transition all => :error, :do => :set_account_error!
    
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
    
    state :processing do
      def call_remote_dwolla_api(args)
        begin
          amount = account.scheduled_amount_at(effective_at).count
          # call the dwolla api
          complete!
        rescue Exception => ex
          self.exception = ex
          handle_error!
        end
      end
    end

    state :completed do
      def complete_records!(args)
        update_attributes(:completed_at => Time.now)
        account.complete!
      end
    end

    state :error do
      def set_account_error!(args)
        account.handle_error!
      end
    end

  end
  
  def log_state_change!(transition)
    payment_events.create!(:created_at => Time.now, 
                           :from_state => transition.from_name, 
                           :to_state => transition.to_name, 
                           :remote_transaction_id => remote_transaction_id, 
                           :raw_response => raw_response,
                           :exception => exception)
  end
  
end