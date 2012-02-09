class PaymentProcessor
  @queue = :payments
  
  def self.perform(payment_id)
    Payment.find(payment_id).process
  end
  
end