FactoryGirl.define do
  factory :scheduled_withdrawal do
    account
    effective_at Time.now
    day_of_month 15
  end
end