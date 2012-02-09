class AccountQueuer
  @queue = :account_queue
  
  def self.perform(args = nil)
    Account.all.map(&:queue)
  end
  
end