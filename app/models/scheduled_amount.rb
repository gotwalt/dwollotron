class ScheduledAmount < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :account_id, :effective_at, :amount
  validate :account_can_have_no_more_than_one_of_these_per_day
  
  scope :effective_at, lambda { |val | where("effective_at <= ?", val.end_of_day).order("effective_at desc").limit(1) }
  
  def account_can_have_no_more_than_one_of_these_per_day
    # no-op unless the record is new or the effective_at has changed
    return unless effective_at_changed? || !persisted?
    one_day = 60 * 60 * 24
    ScheduledAmount.where("account_id = ? and effective_at > ? and effective_at < ?", account_id, effective_at - one_day, effective_at + one_day).each do |existing_amount|
      if effective_at.to_date == existing_amount.effective_at.to_date and existing_amount.id != self.id
        errors.add(:effective_at, "can't be on the same day as another AccountAmount for a given user") 
      end
    end
  end
end