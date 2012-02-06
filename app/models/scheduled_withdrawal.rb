class ScheduledWithdrawal < ActiveRecord::Base
  TIME_WINDOW_OFFSET_IN_SECONDS = 1
  
  belongs_to :account
  validates_presence_of :account_id, :effective_at, :day_of_month
  validate :effective_at_should_not_be_in_the_past, 
           :effective_at_must_be_at_least_next_month_except_new_records
  
  scope :effective_at, lambda { |val | where("effective_at <= ?", val.getgm.end_of_day).order("effective_at desc").limit(1) }
  
  def effective_at_should_not_be_in_the_past
    if (effective_at < Time.now - TIME_WINDOW_OFFSET_IN_SECONDS)
      errors.add(:effective_at, "can't be in the past") 
    end
  end
  
  def effective_at_must_be_at_least_next_month_except_new_records
    # no-op unless the record is new or the effective_at has changed
    return unless effective_at_changed?
    
    if (effective_at <= Time.now.getgm.at_beginning_of_month.next_month) && has_existing_active_scheduled_sibling_withdrawl?
      errors.add(:effective_at, "must be at least next month except new records") 
    end
  end
  
  def has_existing_active_scheduled_sibling_withdrawl?
    existing = ScheduledWithdrawal.where(account_id: account_id).effective_at(Time.now).first
    (existing.present? && existing.id != self.id) == true
  end
  
end