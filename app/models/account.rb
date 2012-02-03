class Account < ActiveRecord::Base
  validates_presence_of :access_token
  has_many :account_amounts
  
  def current_amount
    amount_at Time.now
  end
  
  def amount_at(val)
    raise ArgumentError unless val.is_a?(Time)
    account_amounts.where("active_at <= ?", (val.to_date + 1).to_time - 1).order("active_at desc").first
  end
end