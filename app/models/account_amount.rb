class AccountAmount < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :account_id, :active_at, :amount
  validate :account_can_have_no_more_than_one_of_these_per_day
  
  def account_can_have_no_more_than_one_of_these_per_day
    # no-op unless the record is new or the active_at has changed
    return unless active_at_changed? || !persisted?
    one_day = 60 * 60 * 24
    AccountAmount.where("account_id = ? and active_at > ? and active_at < ?", account_id, active_at - one_day, active_at + one_day).each do |existing_amount|
      if active_at.to_date == existing_amount.active_at.to_date and existing_amount.id != self.id
        errors.add(:active_at, "can't be on the same day as another AccountAmount for a given user") 
      end
    end
  end
end