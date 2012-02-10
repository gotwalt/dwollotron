class AccountQueuer
  @queue = :account_queue
  
  def self.perform(args = nil)
    current_day_of_month = Time.now.getgm.day
    Account.waiting.map do |account|
      nil
      if account.current_withdrawal.day_of_month == current_day_of_month
        account.queue
        true
      end
    end.compact.count
  end
  
end