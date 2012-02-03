FactoryGirl.define do
  factory :account_amount do
    account
    active_at Time.now
    amount 20.0
  end
end