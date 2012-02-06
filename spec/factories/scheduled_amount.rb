FactoryGirl.define do
  factory :scheduled_amount do
    account
    effective_at Time.now
    amount 20.0
  end
end