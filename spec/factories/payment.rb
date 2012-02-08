FactoryGirl.define do
  factory :payment do
    account
    started_at Time.now
    effective_at Time.now
    
    after_create do |payment, proxy|
      FactoryGirl.create(:scheduled_amount, :account => payment.account)
      FactoryGirl.create(:scheduled_withdrawal, :account => payment.account)
    end
  end
end