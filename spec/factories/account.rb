FactoryGirl.define do
  factory :account do
    sequence(:access_token) {|n| "oauth-token-#{n}" }
    pin 1234
  end
end