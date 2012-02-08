class PaymentEvent < ActiveRecord::Base
  belongs_to :payment
  
  validates_presence_of :payment_id, :created_at, :from_state, :to_state
  
  serialize :exception, Yaml
end